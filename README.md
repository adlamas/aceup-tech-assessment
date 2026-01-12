# Engineering Challenge: Ingestion & Identity Management

## 🏗️ Overall Approach & Architecture

- **Unified Record Pattern**: I implemented the **Unified Record Pattern** to handle multiple identities from various sources for the same individual. Instead of a giant table with dozens of attributes that would grow indefinitely with each new source, this approach ensures the system remains scalable and clean. Adding new sources becomes a straightforward process of appending new identities.
- **SOLID Principles**: Focused heavily on the **Single Responsibility Principle (SRP)** by extracting business logic into dedicated Services.
- **MVC Conventions**: Adhered to strict MVC boundaries: controllers act as thin traffic directors, while models and services contain the core business and persistence logic.

## 🗝️ Key Design Decisions

- **N+1 Query Prevention**: Database queries are optimized to eager-load identities, preventing performance bottlenecks.
- **Efficient Pagination**: Integrated the **Pagy** gem, chosen for its exceptional speed and low memory footprint.
- **Error Handling**: Configured a base API controller to standardize error responses across all endpoints.
- **Batch Processing**: My approach to record creation allows for **partial success**. Inspired by platforms like HubSpot, the system processes valid records and reports errors for invalid ones instead of rejecting the entire batch.
- **Testing Strategy**: Tests were designed to cover mission-critical paths and edge cases, such as partial failures in batch operations.
- **Strategic Indexing**: Database indexes were applied to enforce uniqueness (e.g., `external_id` + `source`) and to optimize high-traffic filter fields (`email`, `source`, and `department`).

## 🧬 How Deduplication Works

I maintain deterministic user data in the `Person` model, while source-specific data (CRM, HRM, etc.) resides in the `ExternalIdentity` table. 
The core concern was **horizontal scalability**. With this architecture, adding a new source only requires a new controller/service pair. We avoid massive, sparse records by representing each source as a distinct identity facet of the person—this is the industry standard for identity resolution.



## 🚀 Performance & Scalability

- **Optimized Indexing**: Indexes are placed on all filterable fields to ensure high-performance querying.
- **No N+1 Queries**: Association loading is handled correctly to maintain constant-time performance.
- **Extensibility**: The decoupled architecture allows for new source integration without refactoring existing logic.
- **Readability**: Classes have a single, well-defined purpose, making the codebase easy to audit, modify, or extend.

## 🛠️ Future Improvements (with more time)

- **Test Environment Stability**: Resolve the local host bypass (1) and database cleaning issues (2).
- **Quality Tools**: Integrate **Bullet** for N+1 monitoring and **SimpleCov** for test coverage analysis.
- **CI/CD**: Implementation of automated pipelines using GitHub Actions or CircleCI.
- **Enhanced Test Suite**: Complete the remaining tests for the HRM service and edge cases.
- **Linting**: Full compliance with **Rubocop** style guides.

## ⚠️ Challenges & Known Issues

1. **Database Cleaning**: Encountered an issue where the development database was being cleared during test runs instead of the test database.
2. **Request Test Middleware**: A Rails middleware was blocking RSpec request origins, resulting in 403 Forbidden errors. 


Given the time constraints and the spirit of the challenge, I decided to bypass these infrastructure issues to focus on the core architectural requirements and deliver a functional prototype.



