<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('historial_estados', function (Blueprint $table) {
            $table->id();
            $table->foreignId('denuncia_id')->constrained('denuncias')->cascadeOnDelete();
            $table->enum('estado_anterior', ['pendiente', 'en_proceso', 'resuelta'])->nullable();
            $table->enum('estado_nuevo', ['pendiente', 'en_proceso', 'resuelta']);
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->text('comentario')->nullable();
            $table->timestamp('created_at')->useCurrent();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('historial_estados');
    }
};
