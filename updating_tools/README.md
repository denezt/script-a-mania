# Upgradeing and refactoring code from Java 8 to 21 

### Prerequisites
* Python v3.X
* Linux OS 
* BASH Shell

Upgrading from Java 8 to Java 21 involves a significant leap, as many new features, deprecations, and improvements have been introduced across versions. Here's a comprehensive list of refactoring tasks and areas to focus on for your upgrade:

### 1. **Language Features Refactoring:**
   - **Lambda Expressions & Streams**:
     - Review how you're using streams and lambdas. Consider using `Collectors.toUnmodifiableList()` (introduced in Java 10) if immutability is important.
     - Replace hand-written loops and collection modifications with `Stream` APIs for better readability and performance.
   
   - **Switch Expressions (Java 12/13/14)**:
     - Refactor `switch` statements into the new `switch` expressions where applicable.
     - Example:
       ```java
       String result = switch (day) {
           case MONDAY, FRIDAY, SUNDAY -> "Weekend";
           case TUESDAY -> "Busy day";
           default -> throw new IllegalStateException("Unexpected value: " + day);
       };
       ```
   
   - **Pattern Matching for `instanceof` (Java 16)**:
     - Refactor `instanceof` checks combined with casts to use pattern matching.
     - Example:
       ```java
       if (obj instanceof String s) {
           System.out.println(s.toLowerCase());
       }
       ```

   - **Records (Java 14/16)**:
     - Replace simple data holder classes with `record` types.
     - Example:
       ```java
       public record Person(String name, int age) {}
       ```

   - **Text Blocks (Java 13/14)**:
     - Replace multi-line string concatenations with text blocks.
     - Example:
       ```java
       String html = """
       <html>
           <body>
               <p>Hello, World</p>
           </body>
       </html>""";
       ```

   - **Sealed Classes (Java 17)**:
     - Consider refactoring hierarchy structures using sealed classes where appropriate.
     - Example:
       ```java
       public sealed class Shape permits Circle, Rectangle { }
       public final class Circle extends Shape { }
       public final class Rectangle extends Shape { }
       ```

   - **Var for Local Variables (Java 10)**:
     - Use `var` for local variables when the type is obvious from the context to reduce verbosity.
     - Example:
       ```java
       var list = new ArrayList<String>();
       ```

   - **Enhanced `try-with-resources` (Java 9)**:
     - If you're using Java 8’s `try-with-resources`, you can now simplify this if the resource is already final or effectively final.
     - Example:
       ```java
       MyResource resource = new MyResource();
       try (resource) {
           // Use resource
       }
       ```

### 2. **Library/API Refactoring**:
   - **Collections and Factory Methods (Java 9)**:
     - Replace `Collections.unmodifiableList`/`Set`/`Map` with `List.of()`, `Set.of()`, or `Map.of()` for immutable collections.
     - Example:
       ```java
       List<String> immutableList = List.of("one", "two", "three");
       ```

   - **Optional Enhancements (Java 9/10)**:
     - Refactor `Optional` usage to take advantage of methods like `orElseThrow()` (Java 10), `ifPresentOrElse()`, and `stream()` to make code cleaner and more concise.
     - Example:
       ```java
       optional.ifPresentOrElse(value -> process(value), () -> handleEmpty());
       ```

   - **Deprecation of `Date`/`Calendar`**:
     - Replace usages of `java.util.Date` and `Calendar` with `java.time` APIs (`LocalDate`, `LocalTime`, `Instant`, etc.).
     - Example:
       ```java
       LocalDate date = LocalDate.now();
       ```

   - **Concurrency Utilities (Java 9/10)**:
     - Use `CompletableFuture` improvements and `Flow API` (Reactive Streams) introduced in Java 9.
     - Example:
       ```java
       Flow.Publisher<String> publisher = ...;
       ```

   - **String Methods (Java 11)**:
     - Refactor string manipulations to use methods like `isBlank()`, `lines()`, `strip()`, `repeat()`.
     - Example:
       ```java
       boolean isBlank = string.isBlank();
       String repeated = string.repeat(3);
       ```

### 3. **Modularization (Java 9+)**:
   - **Migrate to Modules**:
     - Consider restructuring your application to use the Java Module System (introduced in Java 9). This might involve creating `module-info.java` files and organizing packages into modules.
     - Example:
       ```java
       module com.example.myapp {
           requires java.base;
           exports com.example.myapp.api;
       }
       ```

   - **Refactor Split Packages**:
     - If your code uses split packages (same package across multiple JARs), refactor them to conform to the module system as this is no longer allowed in Java 9+.

### 4. **Third-Party Library Compatibility**:
   - **Upgrade Libraries**:
     - Ensure that any third-party libraries or frameworks are compatible with Java 21. This may require upgrading or replacing some libraries that are not compatible with the newer JDK.

   - **JPMS (Java Platform Module System) Issues**:
     - Some third-party libraries may not yet support the JPMS. Check if modules like `--add-opens` or `--add-exports` need to be used.

### 5. **Deprecation Handling**:
   - **Identify Deprecated APIs**:
     - Review the code for usage of APIs that have been deprecated since Java 8 (e.g., `Thread.stop()`, `ThreadGroup`, `finalize()` method).
     - Example: Replace `Thread.stop()` with `interrupt()`.

   - **Java EE and CORBA Removal (Java 11)**:
     - Java EE and CORBA modules were removed in Java 11. Refactor your application to remove dependencies on these if any are present (e.g., javax.xml.bind, javax.annotation).

### 6. **Garbage Collector Changes**:
   - **Review GC Settings**:
     - If you have custom GC settings, be aware that new garbage collectors (e.g., ZGC, Shenandoah) have been introduced, and some old ones have changed. The default GC has also changed from Parallel GC (Java 8) to G1GC in Java 9+.
     - Refactor your JVM options and GC configurations accordingly.

### 7. **Security and Cryptography**:
   - **TLS and SSL Protocols**:
     - Java 11 removed support for several outdated cryptographic algorithms and TLS versions. If your application interacts with secure connections, ensure that you're using updated security protocols (e.g., TLS 1.2+).

   - **Reflection and Access Control**:
     - Java 9+ introduced stricter access controls on reflective access to internal classes. Refactor code that relies on reflective access to internal APIs or use the `--add-opens` and `--add-exports` options as temporary measures.

### 8. **Build System and Tooling**:
   - **Upgrade Build Tools (Maven/Gradle)**:
     - Ensure your build tools (Maven/Gradle) and their plugins are compatible with Java 21. Upgrade to the latest versions.
     - Example: If using Maven, ensure that the `maven-compiler-plugin` is set to compile for Java 21.
       ```xml
       <properties>
           <maven.compiler.source>21</maven.compiler.source>
           <maven.compiler.target>21</maven.compiler.target>
       </properties>
       ```

   - **JPMS Support in IDE**:
     - Ensure your IDE (IntelliJ, Eclipse, etc.) is configured to support the Java Platform Module System and Java 21 features.

---

### Checklist for Refactoring:
1. **Language Features**:
   - [ ] Switch to `switch` expressions.
   - [ ] Use pattern matching for `instanceof`.
   - [ ] Replace data holder classes with `record`.
   - [ ] Replace multi-line strings with text blocks.
   - [ ] Implement sealed classes where applicable.
   - [ ] Utilize `var` for local variable type inference.

2. **Library/API Usage**:
   - [ ] Use `List.of()`, `Set.of()`, `Map.of()` for immutable collections.
   - [ ] Refactor `Optional` usage to utilize new methods.
   - [ ] Replace `Date` and `Calendar` with `java.time` APIs.

3. **Modularization**:
   - [ ] Restructure code to use modules (`module-info.java`).

4. **Deprecation**:
   - [ ] Replace deprecated APIs and remove Java EE/CORBA dependencies.

5. **Third-Party Libraries**:
   - [ ] Upgrade libraries for Java 21 compatibility.

6. **GC and JVM Settings**:
   - [ ] Adjust garbage collector settings and JVM options.

7. **Security Updates**:
   - [ ] Ensure updated cryptography and reflection access controls.

8. **Tooling**:
   - [ ] Upgrade build tools (Maven/Gradle) and IDE to support Java 21.

This checklist will helps to systematically refactor your code to be compatible with Java 21.