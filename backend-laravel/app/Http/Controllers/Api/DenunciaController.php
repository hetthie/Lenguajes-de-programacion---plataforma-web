<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreDenunciaRequest;
use App\Http\Requests\UpdateEstadoRequest;
use App\Models\Denuncia;
use App\Models\HistorialEstado;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DenunciaController extends Controller
{
    public function index(Request $request)
    {
        $query = Denuncia::with(['categoria', 'user'])
            ->orderByDesc('created_at');

        if ($request->filled('estado')) {
            $query->where('estado', $request->estado);
        }

        if ($request->filled('categoria_id')) {
            $query->where('categoria_id', $request->categoria_id);
        }

        $denuncias = $query->paginate(15);

        return response()->json([
            'success' => true,
            'data' => $denuncias,
        ]);
    }

    public function store(StoreDenunciaRequest $request)
    {
        $denuncia = DB::transaction(function () use ($request) {
            $denuncia = Denuncia::create([
                'titulo' => $request->titulo,
                'descripcion' => $request->descripcion,
                'categoria_id' => $request->categoria_id,
                'user_id' => $request->user()->id,
                'latitud' => $request->latitud,
                'longitud' => $request->longitud,
                'direccion_referencial' => $request->direccion_referencial,
                'foto_url' => $request->foto_url ?? null,
                'estado' => 'pendiente',
            ]);

            HistorialEstado::create([
                'denuncia_id' => $denuncia->id,
                'estado_anterior' => null,
                'estado_nuevo' => 'pendiente',
                'user_id' => $request->user()->id,
                'comentario' => 'Denuncia registrada en el sistema.',
            ]);

            return $denuncia;
        });

        return response()->json([
            'success' => true,
            'message' => 'Denuncia creada correctamente.',
            'data' => $denuncia->load(['categoria', 'user']),
        ], 201);
    }

    public function show($id)
    {
        $denuncia = Denuncia::with([
            'categoria',
            'user',
            'historialEstados' => fn ($query) => $query->with('user')->orderByDesc('created_at'),
        ])
            ->find($id);

        if (! $denuncia) {
            return response()->json([
                'success' => false,
                'message' => 'Denuncia no encontrada.',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $denuncia,
        ]);
    }

    public function misDenuncias(Request $request)
    {
        $denuncias = Denuncia::with(['categoria'])
            ->where('user_id', $request->user()->id)
            ->orderByDesc('created_at')
            ->paginate(15);

        return response()->json([
            'success' => true,
            'data' => $denuncias,
        ]);
    }

    public function estadisticas()
    {
        return response()->json([
            'success' => true,
            'data' => [
                'total' => Denuncia::count(),
                'pendientes' => Denuncia::where('estado', 'pendiente')->count(),
                'aprobadas' => Denuncia::where('estado', 'resuelta')->count(),
            ],
        ]);
    }

    public function cambiarEstado(UpdateEstadoRequest $request, $id)
    {
        $denuncia = Denuncia::find($id);

        if (! $denuncia) {
            return response()->json([
                'success' => false,
                'message' => 'Denuncia no encontrada.',
            ], 404);
        }

        $estadoAnterior = $denuncia->estado;
        $estadoNuevo = $request->estado;

        if ($estadoAnterior === $estadoNuevo) {
            return response()->json([
                'success' => false,
                'message' => 'La denuncia ya tiene este estado.',
            ], 422);
        }

        DB::transaction(function () use ($denuncia, $request, $estadoAnterior, $estadoNuevo) {
            $denuncia->update([
                'estado' => $estadoNuevo,
            ]);

            HistorialEstado::create([
                'denuncia_id' => $denuncia->id,
                'estado_anterior' => $estadoAnterior,
                'estado_nuevo' => $estadoNuevo,
                'user_id' => $request->user()->id,
                'comentario' => $request->comentario,
            ]);
        });

        return response()->json([
            'success' => true,
            'message' => 'Estado actualizado correctamente.',
            'data' => $denuncia->fresh([
                'categoria',
                'user',
                'historialEstados' => fn ($query) => $query->with('user')->orderByDesc('created_at'),
            ]),
        ]);
    }

    public function historial($id)
    {
        $denuncia = Denuncia::find($id);

        if (! $denuncia) {
            return response()->json([
                'success' => false,
                'message' => 'Denuncia no encontrada.',
            ], 404);
        }

        $historial = $denuncia->historialEstados()
            ->with('user')
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $historial,
        ]);
    }
}
