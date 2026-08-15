<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreDenunciaRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'titulo' => 'required|string|max:150',
            'descripcion' => 'required|string',
            'categoria_id' => 'required|exists:categorias,id',
            'latitud' => 'required|numeric|between:-90,90',
            'longitud' => 'required|numeric|between:-180,180',
            'direccion_referencial' => 'nullable|string|max:255',
            'foto' => 'nullable|image|max:5120',
        ];
    }

    public function messages(): array
    {
        return [
            'titulo.required' => 'El título es obligatorio.',
            'descripcion.required' => 'La descripción es obligatoria.',
            'categoria_id.required' => 'Debe seleccionar una categoría.',
            'categoria_id.exists' => 'La categoría seleccionada no existe.',
            'latitud.required' => 'La ubicación (latitud) es obligatoria.',
            'longitud.required' => 'La ubicación (longitud) es obligatoria.',
            'foto.image' => 'El archivo debe ser una imagen.',
            'foto.max' => 'La imagen no debe superar los 5MB.',
        ];
    }
}
