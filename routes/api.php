<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AdminAuthController;
use App\Http\Controllers\ProjectController; 

 

Route::post('/admin/login', [AdminAuthController::class, 'login']);
Route::middleware('auth:api')->get('/admin/me', [AdminAuthController::class, 'me']);

Route::get('/projects', [ProjectController::class, 'index']);
Route::middleware('auth:api')->group(function () {
    Route::post('/projects', [ProjectController::class, 'store']);
    Route::get('/projects/{id}', [ProjectController::class, 'show']);
    Route::post('/projects/{id}', [ProjectController::class, 'update']);
    Route::delete('/projects/{id}', [ProjectController::class, 'destroy']);
}); 

