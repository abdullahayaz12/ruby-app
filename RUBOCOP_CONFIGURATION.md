# RuboCop Configuration Guide

## Overview

This RuboCop configuration is optimized for **code performance** and **query optimization**, focusing only on rules that impact runtime performance and database efficiency.

## Key Features

### ✅ Performance-Focused Configuration

The configuration includes only **essential performance and query optimization cops**, excluding style-only rules that don't affect functionality.

### ✅ New Code Only

RuboCop is configured to check **only changed files** in CI, not the entire codebase. This allows you to:
- Gradually improve code quality without fixing legacy code immediately
- Faster CI runs
- Focus on new code quality

## Essential Performance Cops Enabled

### Performance Cops (`rubocop-performance`)
- `Performance/Count` - Use `count` instead of `size` for counting records
- `Performance/Detect` - Use `detect` instead of `find.first`
- `Performance/StartWith` - Use `start_with?` instead of regex
- `Performance/EndWith` - Use `end_with?` instead of regex
- `Performance/RegexpMatch` - Use `match?` instead of `=~`
- `Performance/FlatMap` - Use `flat_map` instead of `map.flatten`
- `Performance/MapCompact` - Use `filter_map` instead of `map.compact`
- `Performance/Size` - Use `size` instead of `count` for arrays
- `Performance/StringReplacement` - Use `tr` instead of `gsub` for single character replacements
- `Performance/UnfreezeString` - Avoid unfreezing frozen strings

### Rails Query Optimization Cops (`rubocop-rails`)
- `Rails/FindEach` - Use `find_each` instead of `each` to avoid loading all records
- `Rails/FindBy` - Use `find_by` instead of `where.first`
- `Rails/InverseOf` - Prevent N+1 queries with inverse associations
- `Rails/Pluck` - Use `pluck` instead of `map` when you only need specific attributes
- `Rails/EagerLoading` - Detect N+1 queries and suggest eager loading
- `Rails/UnusedEagerLoading` - Detect unnecessary eager loading
- `Rails/WhereExists` - Use `exists?` instead of `where(...).exists?`
- `Rails/WhereNot` - Use `where.not` instead of `where` with negative conditions
- `Rails/IndexBy` - Use `index_by` for efficient hash creation
- `Rails/IndexWith` - Use `index_with` for efficient hash creation

### Code Quality Metrics
- `Metrics/AbcSize` - Max complexity: 20
- `Metrics/MethodLength` - Max: 30 lines
- `Metrics/ClassLength` - Max: 200 lines
- `Metrics/ParameterLists` - Max: 5 parameters

## Using RuboCop

### Check All Files (Full Scan)
```bash
bundle exec rubocop
```

### Check Only Changed Files (Recommended)
```bash
# Compare with main branch
bin/rubocop-changed main

# Compare with specific branch
bin/rubocop-changed develop
```

### Auto-fix Issues
```bash
# Auto-fix safe issues
bundle exec rubocop -a

# Auto-fix all issues (may change behavior)
bundle exec rubocop -A
```

### Check Specific Files
```bash
bundle exec rubocop app/models/user.rb app/controllers/users_controller.rb
```

## CI Configuration

The CI pipeline automatically:
1. Detects changed Ruby files compared to the base branch
2. Runs RuboCop only on those files
3. Skips RuboCop if no Ruby files changed

This means:
- ✅ Old code won't trigger RuboCop violations
- ✅ Only new/changed code is checked
- ✅ Faster CI runs
- ✅ Gradual code quality improvement

## Excluded Directories

The following directories are excluded from RuboCop checks:
- `db/**/*` - Database migrations and seeds
- `bin/**/*` - Executable scripts
- `config/**/*` - Configuration files
- `vendor/**/*` - Third-party code
- `node_modules/**/*` - Node.js dependencies
- `tmp/**/*` - Temporary files
- `log/**/*` - Log files
- `test/**/*` - Test files (use separate test linting if needed)
- `spec/**/*` - Spec files (use separate spec linting if needed)

## Disabled Style Rules

The following style-only rules are disabled (they don't affect performance):
- `Style/FrozenStringLiteralComment` - Style preference
- `Style/Documentation` - Documentation comments
- `Style/StringLiterals` - Single vs double quotes
- `Style/SymbolArray` - Array syntax preference
- `Style/WordArray` - Array syntax preference
- `Bundler/OrderedGems` - Gem ordering

## Best Practices

1. **Run RuboCop Before Committing**
   ```bash
   bin/rubocop-changed main
   ```

2. **Auto-fix Safe Issues**
   ```bash
   bundle exec rubocop -a
   ```

3. **Review Performance Warnings**
   - Pay special attention to `Rails/EagerLoading` warnings (N+1 queries)
   - Fix `Performance/*` violations for better runtime performance
   - Use `Rails/Pluck` and `Rails/FindEach` for large datasets

4. **Gradually Improve Legacy Code**
   - Old code won't be checked automatically
   - Fix legacy code when you touch those files
   - Use `bundle exec rubocop app/models/legacy_model.rb` to check specific files

## Troubleshooting

### RuboCop is too strict
- The configuration focuses on performance, not style
- If a rule is causing issues, you can disable it in `.rubocop.yml`

### CI is checking old files
- Check the CI logs to see which files are being checked
- The CI compares with the base branch, so ensure your branch is up to date

### Want to check all files
- Run `bundle exec rubocop` locally
- Or temporarily modify CI to remove the file filtering

## Additional Resources

- [RuboCop Performance Docs](https://docs.rubocop.org/rubocop-performance/)
- [RuboCop Rails Docs](https://docs.rubocop.org/rubocop-rails/)
- [RuboCop Configuration](https://docs.rubocop.org/rubocop/configuration/)
