<?php

namespace Database\Seeders;

use App\Models\Categoria;
use Illuminate\Database\Seeder;

class CategoriaSeeder extends Seeder
{
    public function run(): void
    {
        $categorias = [
            'Bache',
            'Alumbrado público dañado',
            'Acumulación de basura',
            'Daño en espacio público',
            'Semáforo dañado',
            'Señalización vial dañada',
            'Fuga de agua',
            'Otro',
        ];

        foreach ($categorias as $nombre) {
            Categoria::firstOrCreate(['nombre' => $nombre]);
        }
    }
}
