<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoriaController;
use App\Http\Controllers\Api\DenunciaController;
use App\Http\Controllers\Api\ReporteController;
use App\Http\Controllers\Api\UserController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::get('/categorias', [CategoriaController::class, 'index']);
    Route::get('/users', [UserController::class, 'index'])->middleware('rol:municipal');

    Route::get('/denuncias', [DenunciaController::class, 'index']);
    Route::post('/denuncias', [DenunciaController::class, 'store']);
    Route::get('/denuncias/mis-denuncias', [DenunciaController::class, 'misDenuncias']);
    // Las rutas literales deben declararse antes de /denuncias/{id}.
    Route::get('/denuncias/mapa', [DenunciaController::class, 'mapa']);
    Route::get('/denuncias/estadisticas', [DenunciaController::class, 'estadisticas'])
        ->middleware('rol:municipal');
    Route::get('/denuncias/{id}', [DenunciaController::class, 'show']);
    Route::patch('/denuncias/{id}/estado', [DenunciaController::class, 'cambiarEstado'])
        ->middleware('rol:municipal');
    Route::get('/denuncias/{id}/historial', [DenunciaController::class, 'historial']);

    Route::middleware('rol:municipal')->prefix('reportes')->group(function () {
        Route::get('/denuncias', [ReporteController::class, 'index']);
        Route::get('/denuncias/csv', [ReporteController::class, 'csv']);
    });
});
