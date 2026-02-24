const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: process.env.APP_VERSION || '1.0.0'
  });
});

app.get('/', (req, res) => {
  res.json({
    message: 'CI/CD Demo Application - DevOps Pipeline',
    environment: process.env.NODE_ENV || 'development',
    version: process.env.APP_VERSION || '1.0.0'
  });
});

app.get('/api/info', (req, res) => {
  res.json({
    app: 'cicd-demo-app',
    company: 'UniSabana',
    description: 'Aplicación de demostración para pipelines CI/CD',
    stack: {
      runtime: 'Node.js',
      framework: 'Express',
      containerization: 'Docker',
      orchestration: 'Kubernetes',
      ci: 'GitHub Actions',
      cd: 'Jenkins'
    }
  });
});

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal Server Error' });
});

if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

module.exports = app;
