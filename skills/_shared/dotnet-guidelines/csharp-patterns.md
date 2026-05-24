# C# Best Practices and .NET Test Patterns

> **Highest priority.** When this document conflicts with generic best practices, **always follow this document**.

---

## C# best practices

### Async/await

- Async methods must use the `Async` suffix.
- Always use `await`.
- Do not use `.Result` or `.Wait()`.

```csharp
// Correct
public async Task<Order> GetOrderAsync(int id, CancellationToken cancellationToken = default)
{
    return await _orderRepository.GetByIdAsync(id, cancellationToken).ConfigureAwait(false);
}

// Wrong — deadlock risk
public Order GetOrder(int id)
{
    return _orderRepository.GetByIdAsync(id).Result;
}
```

### Nullable reference types

```csharp
// Correct
public string OrderNumber { get; init; } = string.Empty;
public string? Notes { get; init; }

// Avoid
public string OrderNumber { get; set; }  // May be null unintentionally
```

### Record types

```csharp
public record OrderDto(int Id, string OrderNumber, DateTime CreatedAt);
public record OrderReference(string Code, string ProductionLine);
```

### Dependency injection

```csharp
public interface IOrderRepository
{
    Task<Order?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Order>> GetAllAsync(CancellationToken cancellationToken = default);
}

services.AddScoped<IOrderRepository, OrderRepository>();
services.AddTransient<IValidator<RegisterOrderCommand>, RegisterOrderCommandValidator>();
```

### IOptions pattern

```csharp
public class OrderService
{
    private readonly OrderOptions _options;

    public OrderService(IOptions<OrderOptions> options)
    {
        _options = options.Value;
    }
}

services.Configure<OrderOptions>(configuration.GetSection("Order"));
```

### Resource management

```csharp
await using var connection = new SqlConnection(connectionString);
await connection.OpenAsync(cancellationToken);

public class IntegrationClient
{
    private readonly HttpClient _httpClient;

    public IntegrationClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }
}
```

---

## .NET test patterns

### Required frameworks (new code)

| Framework | Usage |
|-----------|--------|
| **xUnit** | `[Fact]`, `[Theory]`, `[InlineData]`, `IClassFixture<T>` |
| **FluentAssertions** | Assertions via `.Should().*` |
| **Moq** | Mocks via `new Mock<T>()` / `Mock.Of<T>()` |
| **WireMock.Net** | HTTP stubbing in integration/infrastructure tests (when needed) |

Prefer **xUnit + Moq + FluentAssertions** for all new tests. Legacy NUnit/NSubstitute tests may remain; do not rewrite them unless asked — add new scenarios in new files following this stack.

---

### Test naming (required)

```
Should_<ExpectedResult>_When_<Condition>
```

**Examples:**

- `Should_Register_Order_When_Data_Is_Valid`
- `Should_Return_Error_When_Order_Not_Found`
- `Should_Throw_When_Customer_Is_Inactive`
- `Should_Update_Status_When_Order_Is_Pending`
- `Should_Not_Allow_Delete_When_Order_Is_Approved`
- `Should_Return_Empty_List_When_No_Orders_Exist`

**Rules:**

- Use English identifiers.
- Do not use `Given_When_Then` naming.
- Avoid extra underscores beyond the pattern.

---

### Test structure

- Do not add AAA comments (Arrange, Act, Assert).
- The test name and code should be self-explanatory.
- One test validates **one behavior**.
- No loops or conditional logic inside tests.

```csharp
public class RegisterOrderHandlerTests : IAsyncLifetime
{
    private readonly Mock<IOrderRepository> _orderRepositoryMock = new();
    private IServiceProvider _serviceProvider = null!;

    public async Task InitializeAsync()
    {
        var services = new ServiceCollection();
        services.AddScoped(_ => _orderRepositoryMock.Object);
        services.AddScoped<RegisterOrderHandler>();
        _serviceProvider = services.BuildServiceProvider();
        await Task.CompletedTask;
    }

    public async Task DisposeAsync()
    {
        if (_serviceProvider is IAsyncDisposable asyncDisposable)
            await asyncDisposable.DisposeAsync();
        else if (_serviceProvider is IDisposable disposable)
            disposable.Dispose();
    }

    [Fact]
    public async Task Should_Return_Order_When_Id_Is_Valid()
    {
        var order = OrderFake.CreateValid();
        _orderRepositoryMock
            .Setup(r => r.GetByIdAsync(It.IsAny<int>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(order);
        var command = OrderFake.CreateValidCommand();

        await using var scope = _serviceProvider.CreateAsyncScope();
        var handler = scope.ServiceProvider.GetRequiredService<RegisterOrderHandler>();
        var result = await handler.Handle(command, CancellationToken.None);

        result.Should().NotBeNull();
        result.Id.Should().Be(order.Id);
    }
}
```

**Lifecycle:**

- Prefer **fixture-level** setup (`IAsyncLifetime`, `IClassFixture<T>`) for expensive DI registration and `ServiceProvider` build.
- Per-test reset: `Mock.Reset()` or reconfigure setups when mocks need a clean state.
- Resolve the SUT inside each test with `CreateScope()` when scoped services are involved.

---

### SUT via dependency injection (required)

**Resolve the system under test from the container; do not `new` handlers/services with manual constructor wiring when DI is available.**

Why:

- Constructor changes do not break every test that used `new Handler(dep1, dep2, ...)`.
- DI registration is exercised by tests.
- Mock overrides stay in one place.

```csharp
// Correct
await using var scope = _serviceProvider.CreateAsyncScope();
var handler = scope.ServiceProvider.GetRequiredService<RegisterOrderHandler>();

// Wrong for application services
var handler = new RegisterOrderHandler(_repoMock.Object, _loggerMock.Object);
```

**Override dependencies:**

```csharp
services.AddScoped(_ => _orderRepositoryMock.Object);
services.AddScoped<RegisterOrderHandler>();
```

---

### Naming in tests

- Variables, properties, and methods in **English**.
- Mock variables must use the `Mock` suffix.

```csharp
var orderRepositoryMock = new Mock<IOrderRepository>();
```

---

### Fakes (required for arrange data)

**All DTOs, entities, and collections used in arrange belong in reusable static `*Fake` classes.**

- Place fakes under `Fake/` or `Fixtures/` in the test project.
- Reuse constants in `UPPER_SNAKE_CASE`.
- Factory methods named `Create*` or `Get*` as appropriate.
- Search for existing `*Fake.cs` before adding a new one.
- Do not duplicate construction logic inline in tests.

```csharp
public static class OrderFake
{
    public const string DefaultOrderNumber = "ORD-001";

    public static Order CreateValid(string orderNumber = DefaultOrderNumber) =>
        new() { OrderNumber = orderNumber, IsActive = true };
}
```

**Exception:** static methods that build `[MemberData]` / `[ClassData]` inputs are acceptable on the test class when they are test infrastructure, not domain arrange data.

---

### Moq usage

```csharp
var orderRepositoryMock = new Mock<IOrderRepository>();

orderRepositoryMock
    .Setup(r => r.GetByIdAsync(It.Is<int>(id => id == OrderFake.DefaultId), It.IsAny<CancellationToken>()))
    .ReturnsAsync(order);

orderRepositoryMock
    .Setup(r => r.GetByIdAsync(It.IsAny<int>(), It.IsAny<CancellationToken>()))
    .ReturnsAsync(order);

await handler.Handle(command, CancellationToken.None);

orderRepositoryMock.Verify(
    r => r.SaveAsync(It.IsAny<Order>(), It.IsAny<CancellationToken>()),
    Times.Once);
```

---

### FluentAssertions

```csharp
result.Should().NotBeNull();
result.Should().BeTrue();
result.Should().BeFalse();
result.Should().BeNull();
result.Should().HaveCount(3);
result.Should().Contain(x => x.Id == expectedId);
action.Should().Throw<InvalidOperationException>();

// Avoid classic Assert.That / Assert.Equal for new tests
```

---

### Parameterized tests

Prefer `[Theory]` + `[InlineData]` or `[MemberData]` for multiple scenarios:

```csharp
[Theory]
[InlineData(true)]
[InlineData(false)]
public void Should_Validate_Command(RegisterOrderCommand command, bool expectedValid)
{
    var result = _validator.Validate(command);
    result.IsValid.Should().Be(expectedValid);
}
```

---

### Deterministic tests

- Do not use `DateTime.Now` directly — inject `TimeProvider` or a clock abstraction.
- Do not use uncontrolled `Guid.NewGuid()` when assertions depend on the value.
- Encapsulate non-determinism in fakes or providers.
- Do not rely on implicit ordering.

---

### Integration tests

```csharp
public class OrderApiTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public OrderApiTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task Should_Return_200_When_Order_Exists()
    {
        var response = await _client.GetAsync("/api/orders/1");
        response.StatusCode.Should().Be(HttpStatusCode.OK);
    }
}
```

---

## Blocking test anti-patterns (review checklist)

Any of the following in new `*Test*.cs` / `*Tests.cs` files should be fixed before merge:

| # | Anti-pattern | Fix |
|---|--------------|-----|
| 1 | Manual `new` on injectable handlers/services | Resolve via `GetRequiredService<T>()` |
| 2 | Full DI rebuild in every test method | Move registration to fixture / `IAsyncLifetime` |
| 3 | Inline `new DomainEntity { ... }` in tests | Move to `*Fake` |
| 4 | Private `Create*` / `Build*` helpers on fixture for domain data | Move to `*Fake` |
| 5 | Classic `Assert.*` in new tests | Use FluentAssertions `.Should()` |
| 6 | Test name not `Should_*_When_*` | Rename |
| 7 | `.Result` / `.Wait()` on tasks | Use `await` |

**Accepted patterns:** `IClassFixture<T>`, `CreateScope()`, `*Fake.*`, `Mock<T>`, `.Should()`, `[Theory]`, `Should_*_When_*`.

**Legitimate exceptions:**

- Pure domain entity tests with no DI: `new OrderLine(...)` is fine when the type has no injectable dependencies — still use fakes for complex arrange data.
- `[MemberData]` builders on the test class for xUnit data sources.

Document exceptions in the PR when a rule truly does not apply.
