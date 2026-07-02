import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../environments/environment';

@Injectable({ providedIn: 'root' })
export class ApiService {
  constructor(private readonly http: HttpClient) {}

  health() {
    return this.http.get<{ status: string }>(`${environment.apiUrl}/actuator/health`);
  }

  readiness() {
    return this.http.get<{ status: string }>(
      `${environment.apiUrl}/actuator/health/readiness`,
    );
  }

  work() {
    return this.http.get<{ hits: number; delay_ms: number }>(`${environment.apiUrl}/work`);
  }
}
