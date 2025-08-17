<?php

namespace App\Http\Controllers;

use App\Models\Project;
use Illuminate\Http\Request;

class ProjectController extends Controller
{
    public function index()
    {
        return Project::all();
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string|max:255',
            'technologies' => 'nullable|string|max:255',
            'project_url' => 'nullable|string|max:255',
            'image' => 'nullable|image|max:2048',
        ]);

        if ($request->hasFile('image')) {
            $image = $request->file('image');
            $imageName = uniqid() . '.' . $image->getClientOriginalExtension();
            $image->move(public_path('projects'), $imageName); // public/projects folderinə atılır
            $data['image_path'] = 'projects/' . $imageName; // sadəcə yol (URL üçün)
        }

        $project = Project::create($data); 

        return response()->json($project, 201);
    }

    public function show($id)
    {
        return Project::findOrFail($id);
    }

    public function update(Request $request, $id)
    {
        $project = Project::findOrFail($id);

        $data = $request->validate([
            'title' => 'required|string|max:255',
            'technologies' => 'nullable|string|max:255',
            'project_url' => 'nullable|string|max:255',
            'image' => 'nullable|image|max:2048',
        ]);

        if ($request->hasFile('image')) {
            // Köhnə şəkli sil (əgər varsa)
            if ($project->image_path && file_exists(public_path($project->image_path))) {
                unlink(public_path($project->image_path));
            }

            $image = $request->file('image');
            $imageName = uniqid() . '.' . $image->getClientOriginalExtension();
            $image->move(public_path('projects'), $imageName);
            $data['image_path'] = 'projects/' . $imageName;
        }

        $project->update($data);

        return response()->json($project);
    }

    public function destroy($id)
    {
        $project = Project::findOrFail($id);

        // Şəkli sil
        if ($project->image_path && file_exists(public_path($project->image_path))) {
            unlink(public_path($project->image_path));
        }

        $project->delete();

        return response()->json(null, 204);
    }
}
