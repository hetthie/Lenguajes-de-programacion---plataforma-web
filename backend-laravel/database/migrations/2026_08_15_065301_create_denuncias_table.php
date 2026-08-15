<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('denuncias', function (Blueprint $table) {
            $table->id();
            $table->string('titulo', 150);
            $table->text('descripcion');
            $table->foreignId('categoria_id')->constrained('categorias')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->decimal('latitud', 10, 7);
            $table->decimal('longitud', 10, 7);
            $table->string('direccion_referencial', 255)->nullable();
            $table->string('foto_url', 500)->nullable();
            $table->enum('estado', ['pendiente', 'en_proceso', 'resuelta'])->default('pendiente');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('denuncias');
    }
};
