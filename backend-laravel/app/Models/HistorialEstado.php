<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class HistorialEstado extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'denuncia_id',
        'estado_anterior',
        'estado_nuevo',
        'user_id',
        'comentario',
    ];

    protected $attributes = [
        'created_at' => null,
    ];

    protected static function booted(): void
    {
        static::creating(function ($historial) {
            $historial->created_at = now();
        });
    }

    public function denuncia(): BelongsTo
    {
        return $this->belongsTo(Denuncia::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}

