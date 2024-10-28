import pytest
import os
import tomllib
import importlib
from pathlib import Path

from cocotb.runner import get_runner


@pytest.fixture
def simulator():
	return os.getenv('SIM', 'verilator')


@pytest.fixture
def runner(simulator):
	return get_runner(simulator)


def test_cocotb_testbench(test_module, runner, tmp_path):
	proj_path = Path(__file__).parent
	test_path = tmp_path

	test_module = f'verif.{test_module}'
	
	test_config = importlib.import_module(test_module).__doc__
	test_config = tomllib.loads(test_config)
	test_config.setdefault('parameters', dict())
	
	runner.build(
		sources=test_config['sources'],
		includes=[proj_path / 'design' / 'include'],
		parameters=test_config['parameters'],
		hdl_toplevel=test_config['dut'],
		build_dir=tmp_path / 'build',
	)

	runner.test(
		test_module=test_module,
		hdl_toplevel=test_config['dut'],
		parameters=test_config['parameters'],
		build_dir=tmp_path / 'build',
		test_dir=tmp_path / 'test',
	)


def scan_test_modules():
	verif_path = Path(__file__).parent / 'verif'
	test_modules = []

	for root, dirs, files in os.walk(verif_path):
		for file in files:
			if not (file.startswith('tb_') and file.endswith('.py')):
				continue
			file_path = Path(root) / file
			file_path = file_path.relative_to(verif_path)
			test_modules.append(str(file_path)[:-3].replace('/', '.'))

	return test_modules


def pytest_generate_tests(metafunc):
	if 'test_module' in metafunc.fixturenames:
		metafunc.parametrize('test_module', scan_test_modules())
