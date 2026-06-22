# Modern Angular Architecture & Signals

This document defines core standards for developing modern Angular applications using current framework paradigms, based on the official `angular/skills` guidance.

---

## 1. Standalone Components by Default

* Declare all new `Component`, `Directive`, and `Pipe` instances as **standalone**:
  ```typescript
  @Component({
      selector: 'app-user-profile',
      standalone: true,
      imports: [CommonModule, RouterModule, ButtonComponent],
      templateUrl: './user-profile.component.html',
      styleUrls: ['./user-profile.component.css']
  })
  export class UserProfileComponent { ... }
  ```
* Avoid checking in traditional `NgModule` declarations unless maintaining legacy sub-modules.

---

## 2. Signal-Based State Management

* Use **Signals** (`signal()`, `computed()`) as the primary mechanism to manage local component state and reactivity.
* **Derived State:** Use `computed()` instead of writing triggers inside event methods to update variables.
  ```typescript
  // Correct
  firstName = signal('John');
  lastName = signal('Doe');
  fullName = computed(() => `${this.firstName()} ${this.lastName()}`);
  ```
* **Read-Only Values:** Expose internal signals as read-only `.asReadonly()` to components that consume services.
* **RxJS Integration:** Utilize `toSignal()` to bridge async streams (like HTTP client observables) into signals, and `toObservable()` when you must interface with RxJS pipelines.

---

## 3. Signal Inputs and Queries

* **Inputs:** Use the new signal input syntax (`input()` and `input.required()`) for component input bindings:
  ```typescript
  userId = input.required<string>();
  theme = input<'light' | 'dark'>('light');
  ```
* **Queries:** Use signal-based view queries (`viewChild()`, `viewChildren()`, `contentChild()`) instead of classic `@ViewChild` decorators:
  ```typescript
  canvas = viewChild.required<ElementRef>('myCanvas');
  ```
* **Outputs:** Use the signal-based `output()` declaration instead of `@Output() EventEmitter`.
