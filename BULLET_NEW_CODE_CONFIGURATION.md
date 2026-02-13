# Bullet Configuration for New Code Only

## Overview

Bullet is now configured to check **only new/changed code** by running tests selectively. This approach ensures that:

- ✅ Old code won't trigger Bullet violations
- ✅ Only new code paths are tested
- ✅ Faster CI runs
- ✅ Gradual code quality improvement

## How It Works

### Approach: Test-Based Filtering

Instead of filtering Bullet's output (which is complex), we **run tests only for changed files**. This naturally limits Bullet's detection to code paths exercised by those tests.

**Why this works:**
- Bullet detects N+1 queries at runtime during test execution
- If we only run tests for changed files, Bullet only sees queries from those code paths
- This is simpler and more reliable than trying to filter Bullet's notifications

## Configuration

### 1. CI Workflow (Automatic)

The CI workflow (`.github/workflows/ci.yml`) automatically:

1. **Detects changed files** compared to the base branch
2. **Maps changed application files to test files**:
   - `app/models/user.rb` → `test/models/user_test.rb`
   - `app/controllers/users_controller.rb` → `test/controllers/users_controller_test.rb`
   - `app/helpers/users_helper.rb` → `test/helpers/users_helper_test.rb`
3. **Runs only those tests** with Bullet enabled
4. **Bullet detects N+1 queries** only in code paths exercised by those tests

### 2. Local Testing (Manual)

Use the `bin/test-changed` script to test only changed files locally:

```bash
# Compare with main branch
bin/test-changed main

# Compare with specific branch
bin/test-changed develop
```

**What it does:**
- Finds changed application files (`app/`, `lib/`)
- Maps them to corresponding test files
- Runs only those tests with Bullet enabled
- Bullet will detect N+1 queries in those code paths

## File Mapping

The script automatically maps changed files to test files:

| Changed File | Test File |
|-------------|-----------|
| `app/models/user.rb` | `test/models/user_test.rb` |
| `app/controllers/users_controller.rb` | `test/controllers/users_controller_test.rb` |
| `app/helpers/users_helper.rb` | `test/helpers/users_helper_test.rb` |
| `app/jobs/email_job.rb` | `test/jobs/email_job_test.rb` |
| `app/mailers/user_mailer.rb` | `test/mailers/user_mailer_test.rb` |
| `test/controllers/users_controller_test.rb` | (runs directly) |

## Examples

### Example 1: Changed Model File

```bash
# You changed app/models/user.rb
bin/test-changed main

# Output:
# 🔍 Changed application files:
#   - app/models/user.rb
# 🧪 Running tests for changed files:
#   - test/models/user_test.rb
# 
# [Tests run, Bullet detects N+1 queries in User model code paths]
```

### Example 2: Changed Controller File

```bash
# You changed app/controllers/users_controller.rb
bin/test-changed main

# Output:
# 🔍 Changed application files:
#   - app/controllers/users_controller.rb
# 🧪 Running tests for changed files:
#   - test/controllers/users_controller_test.rb
# 
# [Tests run, Bullet detects N+1 queries in UsersController code paths]
```

### Example 3: Multiple Changed Files

```bash
# You changed multiple files
bin/test-changed main

# Output:
# 🔍 Changed application files:
#   - app/models/user.rb
#   - app/controllers/users_controller.rb
# 🧪 Running tests for changed files:
#   - test/models/user_test.rb
#   - test/controllers/users_controller_test.rb
# 
# [All relevant tests run, Bullet detects N+1 queries in all changed code paths]
```

## CI Behavior

### Pull Requests

When you create a PR:
1. CI detects files changed compared to base branch
2. Maps to test files
3. Runs only those tests
4. Bullet detects N+1 queries only in changed code paths
5. CI fails if Bullet detects issues

### Direct Pushes

When you push directly to `main` or `develop`:
1. CI detects files changed compared to previous commit
2. Maps to test files
3. Runs only those tests
4. Bullet detects N+1 queries only in changed code paths

## Benefits

### ✅ Faster CI Runs
- Only runs tests for changed files
- Much faster than running all tests
- Especially beneficial for large codebases

### ✅ Focused Feedback
- Bullet only reports issues in new code
- Easier to fix issues when they're introduced
- No noise from legacy code

### ✅ Gradual Improvement
- Old code won't block new code
- Can fix legacy code incrementally
- New code maintains high quality

### ✅ Better Developer Experience
- Faster feedback loop
- Clearer error messages
- Less overwhelming

## Limitations

### ⚠️ Integration Tests

If you have integration/system tests that test multiple files:
- They won't run automatically unless one of the tested files changed
- You may need to manually run full test suite before merging
- Consider adding integration tests to the mapping logic

### ⚠️ Cross-File Dependencies

If changed code affects other files:
- Tests for those files won't run automatically
- Consider running full test suite before merging critical changes
- Use `bundle exec rails test` to run all tests when needed

### ⚠️ New Files Without Tests

If you add new application files without corresponding tests:
- Script will run all tests as a fallback (doesn't fail)
- **Bullet might miss N+1 queries** if no test exercises the new code
- **Recommendation:** Add tests for database-related code (models, controllers)
- See `TESTING_EXPLAINED.md` for detailed explanation

## Best Practices

### 1. Run Tests Locally Before Pushing

```bash
# Test changed files locally
bin/test-changed main

# If you want to test everything
bundle exec rails test
```

### 2. Add Tests for New Files

When adding new application files, add corresponding test files:
- `app/models/user.rb` → `test/models/user_test.rb`
- `app/controllers/users_controller.rb` → `test/controllers/users_controller_test.rb`

### 3. Run Full Test Suite Before Merging

For critical changes, run the full test suite:
```bash
bundle exec rails test
```

### 4. Monitor CI Results

- Check CI logs to see which tests ran
- Verify Bullet detected issues only in changed code
- Fix any N+1 queries before merging

## Troubleshooting

### Tests Not Running

**Problem:** Script says "No test files found"

**Solution:**
- Ensure test files follow Rails naming conventions
- Check that test files exist in the expected locations
- Script will run all tests as fallback

### Bullet Not Detecting Issues

**Problem:** Bullet should detect N+1 but doesn't

**Solution:**
- Ensure `BULLET_ENABLED=true` is set
- Check that tests actually exercise the code path
- Verify Bullet configuration in `config/initializers/bullet.rb`

### Too Many Tests Running

**Problem:** Script runs more tests than expected

**Solution:**
- Check which files changed: `git diff --name-only main...HEAD`
- Verify file mapping logic matches your test structure
- Adjust mapping logic in `bin/test-changed` if needed

## Advanced: Custom Filtering (Optional)

If you need more control, you can use the `lib/bullet_filter.rb` module to filter Bullet notifications by file path. This is more complex but gives you fine-grained control.

See `lib/bullet_filter.rb` for implementation details.

## Summary

Bullet now checks only new code by:
1. ✅ Running tests only for changed files
2. ✅ Bullet detects N+1 queries in those code paths
3. ✅ CI automatically uses this approach
4. ✅ Use `bin/test-changed` locally

This ensures old code won't trigger Bullet violations while maintaining high quality for new code!
