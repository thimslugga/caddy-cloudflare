"""Tests for the Caddy release lookup script."""

import io
from importlib.util import module_from_spec, spec_from_file_location
from pathlib import Path

import pytest

SCRIPT_PATH = Path(__file__).with_name("get-latest-caddy-release.py")
SCRIPT_SPEC = spec_from_file_location("get_latest_caddy_release", SCRIPT_PATH)
assert SCRIPT_SPEC is not None
assert SCRIPT_SPEC.loader is not None
SCRIPT = module_from_spec(SCRIPT_SPEC)
SCRIPT_SPEC.loader.exec_module(SCRIPT)


def test_get_latest_release_removes_v_prefix(monkeypatch: pytest.MonkeyPatch) -> None:
    """Return a plain version for a valid GitHub release response."""
    response = io.BytesIO(b'{"tag_name": "v2.11.4"}')
    monkeypatch.setattr(SCRIPT, "urlopen", lambda request, timeout: response)

    assert SCRIPT.get_latest_release() == "2.11.4"


def test_get_latest_release_rejects_missing_tag(monkeypatch: pytest.MonkeyPatch) -> None:
    """Reject a GitHub response that omits the release tag."""
    response = io.BytesIO(b"{}")
    monkeypatch.setattr(SCRIPT, "urlopen", lambda request, timeout: response)

    with pytest.raises(SCRIPT.InvalidReleaseResponseError):
        SCRIPT.get_latest_release()


def test_main_prints_release(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Write a successful lookup to stdout and return success."""
    monkeypatch.setattr(SCRIPT, "get_latest_release", lambda: "2.11.4")

    assert SCRIPT.main() == 0
    captured = capsys.readouterr()
    assert captured.out == "2.11.4\n"
    assert captured.err == ""


def test_main_reports_lookup_failure(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Write lookup failures to stderr and return a failure status."""
    error = SCRIPT.InvalidReleaseResponseError()

    def fail_lookup() -> str:
        raise error

    monkeypatch.setattr(SCRIPT, "get_latest_release", fail_lookup)

    assert SCRIPT.main() == 1
    captured = capsys.readouterr()
    assert captured.out == ""
    assert "valid 'tag_name'" in captured.err
