<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

#[Fillable(['name', 'email', 'password','rol'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable
{
    public function denuncias(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Denuncia::class);
    }

    public function historialEstados(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(HistorialEstado::class);
    }
    /** @use HasFactory<UserFactory> */
    use HasFactory, Notifiable,HasApiTokens;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }
}
