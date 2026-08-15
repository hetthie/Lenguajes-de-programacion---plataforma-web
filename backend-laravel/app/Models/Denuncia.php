<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Denuncia extends Model
{
    use HasFactory;

    protected $fillable = [
        'titulo',
        'descripcion',
        'categoria_id',
        'user_id',
        'latitud',
        'longitud',
        'direccion_referencial',
        'foto_url',
        'estado',
    ];

    protected $casts = [
        'latitud' => 'decimal:7',
        'longitud' => 'decimal:7',
    ];

    public function categoria(): BelongsTo
    {
        return $this->belongsTo(Categoria::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function historialEstados(): HasMany
    {
        return $this->hasMany(HistorialEstado::class);
    }
}
