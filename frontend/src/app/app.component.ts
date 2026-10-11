import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  standalone: true,
  template: `
    <div class="min-h-screen bg-gray-100 flex items-center justify-center">
      <div class="text-center">
        <h1 class="text-4xl font-bold text-gray-900 mb-4">DevSanar</h1>
        <p class="text-gray-600">Fórum de Perguntas e Respostas para Desenvolvedores</p>
      </div>
    </div>
  `,
  styles: []
})
export class AppComponent {
  title = 'DevSanar';
}
