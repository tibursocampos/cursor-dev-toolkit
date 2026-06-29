# Front-end Best Practices

When developing web applications and front-end interfaces, we adhere to modern standards prioritizing clean aesthetics, responsive design, and robust code.

## Technology Stack

1. **Core**: Use standard HTML for structure and JavaScript/TypeScript for logic.
2. **Styling (CSS)**: Use Vanilla CSS for maximum flexibility and control. Avoid utility-first frameworks like TailwindCSS unless explicitly required by the project specifications.
3. **Frameworks**: For complex web applications, utilize modern frameworks such as Next.js or Vite (React/Vue). 

## Design and Aesthetics

- **Use Rich Aesthetics**: Designs should be modern, beautiful, and dynamic. Utilize vibrant but curated color palettes (e.g., HSL tailored colors), sleek dark modes, glassmorphism, and smooth gradients.
- **Modern Typography**: Use web fonts (like Inter, Roboto, or Outfit) instead of default browser fonts.
- **Dynamic Interfaces**: Implement micro-animations and hover effects to make the interface feel alive and responsive to user interaction.

## SEO and Semantic HTML

Always implement SEO best practices on every page:
- **Semantic HTML**: Use appropriate HTML5 semantic elements (`<header>`, `<main>`, `<article>`, `<section>`, `<footer>`).
- **Title Tags & Meta Descriptions**: Ensure each page has accurate, descriptive tags.
- **Heading Hierarchy**: Use a single `<h1>` per page, followed by logical heading hierarchies (`<h2>`, `<h3>`).
- **Accessibility**: Ensure all interactive elements have descriptive IDs and ARIA labels where appropriate.

## Code Formatting

Similar to our backend standards, we enforce strict formatting on the frontend:
- Use **Prettier** for automatic formatting of JavaScript, TypeScript, CSS, and HTML files.
- Use **ESLint** for static code analysis to catch potential bugs and enforce coding standards.
- Integrate these tools with Git pre-commit hooks (e.g., Husky) to ensure code is clean before it reaches the remote repository.

---

## AI Stealth Policy

- **Comments:** Minimal and only when strictly necessary. No AI references in HTML, CSS, or JavaScript/TypeScript comments.
- **Identifiers:** No AI-derived names (`aiResult`, `llmOutput`, `generatedContent`, etc.).
- **No AI traces** in any code, markup, or comments. Output must be indistinguishable from work produced without AI assistance.
- See `GUARDRAILS.md` § 9.
