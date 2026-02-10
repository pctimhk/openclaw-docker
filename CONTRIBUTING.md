# Contributing to OpenClaw Docker for Synology

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## How to Contribute

### Reporting Issues

If you encounter a problem:

1. **Search existing issues** to avoid duplicates
2. **Use the issue template** if available
3. **Include details**:
   - Synology model and DSM version
   - Docker version
   - Steps to reproduce
   - Expected vs actual behavior
   - Relevant logs (redact sensitive information)
   - Screenshots if applicable

### Suggesting Enhancements

For feature requests:

1. **Check existing issues** for similar suggestions
2. **Explain the use case** - why is this useful?
3. **Provide examples** of how it would work
4. **Consider alternatives** - are there other ways to achieve this?

### Pull Requests

We welcome pull requests! Here's how:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. **Make your changes**
4. **Test thoroughly** on a Synology NAS if possible
5. **Update documentation** if needed
6. **Commit with clear messages**
7. **Push to your fork**
8. **Open a pull request**

## Development Guidelines

### Code Style

**Shell Scripts:**
- Use `#!/bin/bash` shebang
- Use `set -e` for error handling
- Quote variables: `"$VARIABLE"`
- Use meaningful variable names
- Add comments for complex logic

**Docker Files:**
- Keep images small (use Alpine)
- Combine RUN commands where appropriate
- Order commands by change frequency
- Use `.dockerignore` to exclude unnecessary files
- Add comments for clarity

**YAML Files:**
- Use 2-space indentation
- Quote strings when needed
- Keep it readable with proper spacing
- Validate with `docker compose config`

### Documentation

- Keep README.md up to date
- Update SYNOLOGY_GUIDE.md for detailed instructions
- Add examples where helpful
- Use clear, concise language
- Include troubleshooting tips
- Test all instructions

### Testing

Before submitting a PR:

- [ ] Build succeeds: `docker build -t openclaw:latest .`
- [ ] Compose config validates: `docker compose config`
- [ ] Scripts are executable: `chmod +x *.sh`
- [ ] Documentation is accurate
- [ ] No sensitive information in commits
- [ ] `.gitignore` excludes generated files

### Commit Messages

Use clear, descriptive commit messages:

```
Good:
- "Add health check to Dockerfile"
- "Fix port mapping in docker-compose.yml"
- "Update SYNOLOGY_GUIDE.md with backup instructions"

Avoid:
- "Fix bug"
- "Update files"
- "Changes"
```

## Areas for Contribution

### High Priority

- [ ] Testing on different Synology models
- [ ] Testing on different DSM versions
- [ ] Performance optimization suggestions
- [ ] Security improvements
- [ ] Documentation improvements

### Medium Priority

- [ ] Additional helper scripts
- [ ] Alternative deployment methods
- [ ] Integration with other services
- [ ] Monitoring and alerting examples
- [ ] Automated backup solutions

### Low Priority

- [ ] UI improvements (if applicable)
- [ ] Additional examples
- [ ] Localization/translation
- [ ] Blog posts or tutorials

## Specific Contribution Ideas

### Testing

We need testing on:
- Various Synology models (DS920+, DS1621+, etc.)
- Different DSM versions (7.0, 7.1, 7.2, etc.)
- Resource-constrained environments
- High-load scenarios

### Documentation

Help improve:
- Common error messages and solutions
- Performance tuning guides
- Security hardening tips
- Migration guides
- Video tutorials

### Features

Consider adding:
- Automated update scripts
- Backup/restore tools
- Monitoring dashboards
- Log analysis tools
- Multi-instance management

### Integration

Ideas for integration:
- Synology task scheduler
- Synology notifications
- Synology surveillance
- External monitoring (Prometheus, Grafana)
- Reverse proxy configurations (Traefik, Nginx)

## Code Review Process

1. **Maintainer reviews** pull request
2. **Feedback provided** if changes needed
3. **Discussion** if questions arise
4. **Approval** when ready
5. **Merge** into main branch
6. **Thanks** for your contribution!

## Community Guidelines

### Be Respectful

- Use welcoming and inclusive language
- Respect differing viewpoints
- Accept constructive criticism
- Focus on what's best for the community

### Be Collaborative

- Help others when you can
- Share knowledge and experiences
- Credit contributors appropriately
- Be patient with newcomers

### Be Responsible

- Test your changes before submitting
- Don't commit sensitive information
- Follow security best practices
- Report security issues privately

## Getting Help

Need help contributing?

- **OpenClaw Discord**: https://discord.gg/clawd
- **GitHub Discussions**: Use the Discussions tab
- **Email**: Open an issue for questions

## Recognition

Contributors will be:
- Listed in the repository
- Mentioned in release notes
- Thanked in the community

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

Don't hesitate to ask! Open an issue with the label `question` or reach out via Discord.

---

Thank you for contributing to making OpenClaw accessible to Synology users! 🎉
