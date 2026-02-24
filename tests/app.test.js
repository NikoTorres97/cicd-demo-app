const request = require('supertest');
const app = require('../src/app');

describe('Application Endpoints', () => {
  describe('GET /', () => {
    it('should return welcome message with status 200', async () => {
      const res = await request(app).get('/');
      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('message');
      expect(res.body.message).toContain('CI/CD Demo Application');
    });
    it('should return JSON content type', async () => {
      const res = await request(app).get('/');
      expect(res.headers['content-type']).toMatch(/json/);
    });
  });

  describe('GET /health', () => {
    it('should return healthy status', async () => {
      const res = await request(app).get('/health');
      expect(res.statusCode).toBe(200);
      expect(res.body.status).toBe('healthy');
      expect(res.body).toHaveProperty('timestamp');
    });
  });

  describe('GET /api/info', () => {
    it('should return application info', async () => {
      const res = await request(app).get('/api/info');
      expect(res.statusCode).toBe(200);
      expect(res.body.app).toBe('cicd-demo-app');
      expect(res.body.stack).toHaveProperty('ci');
      expect(res.body.stack).toHaveProperty('cd');
    });
    it('should include complete stack information', async () => {
      const res = await request(app).get('/api/info');
      const { stack } = res.body;
      expect(stack.runtime).toBe('Node.js');
      expect(stack.ci).toBe('GitHub Actions');
      expect(stack.cd).toBe('Jenkins');
      expect(stack.orchestration).toBe('Kubernetes');
    });
  });

  describe('GET /nonexistent', () => {
    it('should return 404 for unknown routes', async () => {
      const res = await request(app).get('/nonexistent');
      expect(res.statusCode).toBe(404);
    });
  });
});
