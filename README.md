# Zalpaca

Open-source Alpaca Markets API SDK for Zig 0.16.0. **Early development**.

## Current features

- `Config`: API credentials and paper/live selection. Paper by default.
- `Client`: owns copies of credentials and a reusable HTTP transport, and selects the trading endpoint dynamically.
- `Transport.get`: sends a GET request with caller-supplied headers and returns the HTTP status and an owned response body.

Typed endpoint methods and `Config.url_override` support are not implemented yet.

## Tests

Requires Zig 0.16.0. NO EXTERNAL DEPENDENCIES

```sh
zig build test              # Run offline unit tests
zig build test-unit         # Same unit suite
zig build check             # Check both suites without running them
zig build test-integration  # Run the authenticated HTTP integration test
```

Unit tests cover configuration, client initialization, and transport initialization. The integration test requests the paper account endpoint and checks HTTP 200, a nonempty body, and a valid JSON object.

Integration test requires network access and paper account credentials in `APCA_API_KEY_ID` and `APCA_API_SECRET_KEY`.

## Planned updates and features

- Add a typed account method and define ownership of parsed data.
- Test credential ownership and allocation failures.
- Add controlled transport tests for errors and body limits.
- Implement URL overrides.

## License

Apache 2.0. See [LICENSE](LICENSE).
