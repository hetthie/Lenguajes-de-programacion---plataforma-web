<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateEstadoRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'estado' => 'required|in:pendiente,en_proceso,resuelta',
            'comentario' => 'nullable|string|max:500',
        ];
    }

    public function messages(): array
    {
        return [
            'estado.required' => 'Debe indicar el nuevo estado.',
            'estado.in' => 'El estado debe ser: pendiente, en_proceso o resuelta.',
        ];
    }
}
