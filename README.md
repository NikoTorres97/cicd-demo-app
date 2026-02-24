# CI/CD Demo Application

Aplicación web con pipelines de **CI** (GitHub Actions) y **CD** (Jenkins), desplegada en **Kubernetes**.

## Estructura
```
├── .github/workflows/ci.yml   # Pipeline CI (GitHub Actions)
├── src/app.js                  # Aplicación Express.js
├── tests/app.test.js           # Pruebas unitarias (Jest)
├── k8s/deployment.yaml         # Manifiestos Kubernetes
├── Dockerfile                  # Build multi-stage
├── Jenkinsfile                 # Pipeline CD (Jenkins)
└── README.md
```

## Flujo CI/CD
```
Developer → push → GitHub Actions (CI) → Docker → DockerHub → Jenkins (CD) → Kubernetes
```

## Ramas
| Rama | Propósito |
|------|-----------|
| `main` | Producción (protegida, requiere PR + CI verde) |
| `desarrollo_DevOps | Integración/desarrollo (rama default) |
| `feature/ci-pipeline` | Pipeline CI con GitHub Actions |
| `feature/cd-pipeline` | Pipeline CD con Jenkins |
| `feature/k8s-infra` | Infraestructura Kubernetes |

## Ejecución Local
```bash
npm install && npm test && npm start
```

## Docker
```bash
docker build -t cicd-demo-app .
docker run -p 3000:3000 cicd-demo-app
```

## Equipo
**Nicolas Torres / Juan Perez
