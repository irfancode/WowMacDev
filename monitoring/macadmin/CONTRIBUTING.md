# Contributing to MacAdmin

Thank you for your interest in contributing to MacAdmin! This document provides guidelines for contributing.

## Development Setup

### Prerequisites
- Node.js 20+
- Python 3.11+
- Docker & Docker Compose (optional but recommended)

### Frontend Development

```bash
cd frontend
npm install
npm run dev
```

The development server will start at `http://localhost:5173`

### Backend Development

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python -m app.main
```

The API will be available at `http://localhost:8000`

## Code Style

### Frontend
- Use TypeScript for all new code
- Follow existing component patterns
- Use Tailwind CSS for styling
- Ensure dark mode compatibility

### Backend
- Follow PEP 8 style guide
- Use type hints
- Write docstrings for functions

## Pull Request Process

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Make your changes
4. Test thoroughly
5. Commit with descriptive messages
6. Push to your fork
7. Open a Pull Request

## Commit Message Format

```
type(scope): subject

body (optional)
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Tests
- `chore`: Maintenance

## Testing

### Frontend
```bash
npm run typecheck
npm run lint
```

### Backend
```bash
python -m pytest
```

## Reporting Issues

- Use GitHub Issues
- Provide detailed description
- Include steps to reproduce
- Add screenshots if applicable

## Code of Conduct

Be respectful and constructive in all interactions.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
