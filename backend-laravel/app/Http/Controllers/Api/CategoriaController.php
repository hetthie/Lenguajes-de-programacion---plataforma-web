<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Categoria;

class CategoriaController extends Controller
{
    public function index()
    {
        $categorias = Categoria::select('id', 'nombre')
            ->orderBy('nombre')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $categorias,
        ]);
    }
}
