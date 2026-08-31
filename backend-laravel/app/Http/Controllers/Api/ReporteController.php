<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Denuncia;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ReporteController extends Controller
{
    public function index(Request $request)
    {
        $filters = $this->validateFilters($request);
        $denuncias = $this->query($filters)->get();

        $porCategoria = $denuncias
            ->groupBy(fn (Denuncia $denuncia) => $denuncia->categoria?->nombre ?? 'Sin categoria')
            ->map(fn ($items, string $categoria) => [
                'categoria' => $categoria,
                'total' => $items->count(),
            ])
            ->sortByDesc('total')
            ->values();

        return response()->json([
            'success' => true,
            'data' => [
                'resumen' => [
                    'total' => $denuncias->count(),
                    'pendientes' => $denuncias->where('estado', 'pendiente')->count(),
                    'en_proceso' => $denuncias->where('estado', 'en_proceso')->count(),
                    'resueltas' => $denuncias->where('estado', 'resuelta')->count(),
                ],
                'por_categoria' => $porCategoria,
                'denuncias' => $denuncias,
            ],
        ]);
    }

    public function csv(Request $request): StreamedResponse
    {
        $filters = $this->validateFilters($request);
        $denuncias = $this->query($filters)->get();
        $fileName = 'reporte_denuncias_'.now()->format('Ymd_His').'.csv';

        return response()->streamDownload(function () use ($denuncias) {
            $output = fopen('php://output', 'w');

            // BOM UTF-8 para que Excel reconozca correctamente tildes y enes.
            fwrite($output, "\xEF\xBB\xBF");
            fputcsv($output, [
                'ID',
                'Fecha',
                'Titulo',
                'Categoria',
                'Estado',
                'Direccion',
                'Ciudadano',
                'Correo',
                'Latitud',
                'Longitud',
            ], ';');

            foreach ($denuncias as $denuncia) {
                fputcsv($output, [
                    $denuncia->id,
                    $denuncia->created_at?->format('Y-m-d H:i:s'),
                    $this->safeSpreadsheetValue($denuncia->titulo),
                    $this->safeSpreadsheetValue($denuncia->categoria?->nombre),
                    $denuncia->estado,
                    $this->safeSpreadsheetValue($denuncia->direccion_referencial),
                    $this->safeSpreadsheetValue($denuncia->user?->name),
                    $this->safeSpreadsheetValue($denuncia->user?->email),
                    $denuncia->latitud,
                    $denuncia->longitud,
                ], ';');
            }

            fclose($output);
        }, $fileName, [
            'Content-Type' => 'text/csv; charset=UTF-8',
        ]);
    }

    private function validateFilters(Request $request): array
    {
        return $request->validate([
            'desde' => 'nullable|date',
            'hasta' => 'nullable|date|after_or_equal:desde',
            'estado' => 'nullable|in:pendiente,en_proceso,resuelta',
            'categoria_id' => 'nullable|integer|exists:categorias,id',
        ]);
    }

    private function query(array $filters): Builder
    {
        return Denuncia::with(['categoria', 'user'])
            ->when(
                ! empty($filters['desde']),
                fn (Builder $query) => $query->whereDate('created_at', '>=', $filters['desde'])
            )
            ->when(
                ! empty($filters['hasta']),
                fn (Builder $query) => $query->whereDate('created_at', '<=', $filters['hasta'])
            )
            ->when(
                ! empty($filters['estado']),
                fn (Builder $query) => $query->where('estado', $filters['estado'])
            )
            ->when(
                ! empty($filters['categoria_id']),
                fn (Builder $query) => $query->where('categoria_id', $filters['categoria_id'])
            )
            ->orderByDesc('created_at');
    }

    /** Evita que una celda de texto sea interpretada como formula por Excel. */
    private function safeSpreadsheetValue(?string $value): string
    {
        $value ??= '';

        return preg_match('/^[=+\-@]/u', ltrim($value)) ? "'".$value : $value;
    }
}
