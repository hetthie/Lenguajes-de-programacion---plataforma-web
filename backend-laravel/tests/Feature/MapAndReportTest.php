<?php

namespace Tests\Feature;

use App\Models\Categoria;
use App\Models\Denuncia;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MapAndReportTest extends TestCase
{
    use RefreshDatabase;

    public function test_public_registration_cannot_create_a_municipal_account(): void
    {
        $response = $this->postJson('/api/register', [
            'name' => 'Ciudadano de prueba',
            'email' => 'ciudadano@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'rol' => 'municipal',
        ]);

        $response
            ->assertCreated()
            ->assertJsonPath('user.rol', 'ciudadano');

        $this->assertDatabaseHas('users', [
            'email' => 'ciudadano@example.com',
            'rol' => 'ciudadano',
        ]);
    }

    public function test_authenticated_user_can_get_every_complaint_for_the_map(): void
    {
        [$citizen] = $this->seedComplaint();
        $secondCitizen = User::factory()->create(['rol' => 'ciudadano']);
        $category = Categoria::first();

        Denuncia::create([
            'titulo' => 'Luminaria dañada',
            'descripcion' => 'La luminaria no enciende.',
            'categoria_id' => $category->id,
            'user_id' => $secondCitizen->id,
            'latitud' => -2.1700000,
            'longitud' => -79.9000000,
            'direccion_referencial' => 'Norte de Guayaquil',
            'estado' => 'en_proceso',
        ]);

        Sanctum::actingAs($citizen);

        $this->getJson('/api/denuncias/mapa')
            ->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('data.0.categoria.nombre', $category->nombre);
    }

    public function test_only_municipal_users_can_generate_reports(): void
    {
        [$citizen] = $this->seedComplaint();

        Sanctum::actingAs($citizen);
        $this->getJson('/api/reportes/denuncias')->assertForbidden();

        $municipal = User::factory()->create(['rol' => 'municipal']);
        Sanctum::actingAs($municipal);

        $this->getJson('/api/reportes/denuncias')
            ->assertOk()
            ->assertJsonPath('data.resumen.total', 1)
            ->assertJsonPath('data.resumen.pendientes', 1)
            ->assertJsonCount(1, 'data.denuncias');
    }

    public function test_municipal_user_can_download_the_filtered_csv(): void
    {
        $this->seedComplaint();
        $municipal = User::factory()->create(['rol' => 'municipal']);
        Sanctum::actingAs($municipal);

        $response = $this->get('/api/reportes/denuncias/csv?estado=pendiente');

        $response->assertOk();
        $content = $response->streamedContent();
        $this->assertStringContainsString('Titulo', $content);
        $this->assertStringContainsString('Bache de prueba', $content);
    }

    /** @return array{User, Denuncia} */
    private function seedComplaint(): array
    {
        $citizen = User::factory()->create(['rol' => 'ciudadano']);
        $category = Categoria::create(['nombre' => 'Bache']);
        $complaint = Denuncia::create([
            'titulo' => 'Bache de prueba',
            'descripcion' => 'Existe un bache peligroso.',
            'categoria_id' => $category->id,
            'user_id' => $citizen->id,
            'latitud' => -2.1894000,
            'longitud' => -79.8891000,
            'direccion_referencial' => 'Centro de Guayaquil',
            'estado' => 'pendiente',
        ]);

        return [$citizen, $complaint];
    }
}
