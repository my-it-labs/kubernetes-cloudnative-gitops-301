import { Component, OnInit, signal } from '@angular/core';
import { ApiService } from './api.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [],
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App implements OnInit {
  protected readonly title = signal('Kubernetes + Docker Avanzado');
  protected readonly health = signal<string>('comprobando…');
  protected readonly readiness = signal<string>('n/a en M01');
  protected readonly hits = signal<number | null>(null);
  protected readonly error = signal<string | null>(null);
  protected readonly loading = signal(false);

  constructor(private readonly api: ApiService) {}

  ngOnInit(): void {
    this.refreshHealth();
  }

  refreshHealth(): void {
    this.api.health().subscribe({
      next: (body: { status?: string }) => this.health.set(body.status ?? 'ok'),
      error: () => this.health.set('error'),
    });
  }

  checkReadiness(): void {
    this.api.readiness().subscribe({
      next: (body: { status?: string }) => this.readiness.set(body.status ?? 'ready'),
      error: () => this.readiness.set('not ready / 404 en M01'),
    });
  }

  doWork(): void {
    this.loading.set(true);
    this.error.set(null);
    this.api.work().subscribe({
      next: (body: { hits: number }) => {
        this.hits.set(body.hits);
        this.loading.set(false);
      },
      error: (err: unknown) => {
        this.error.set(err instanceof Error ? err.message : 'error');
        this.loading.set(false);
      },
    });
  }
}
