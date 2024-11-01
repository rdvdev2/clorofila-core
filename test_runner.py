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


def test_cocotb_testbench(test_module, runner):
	proj_path = Path(__file__).parent
	test_path = proj_path / 'verif_out' / test_module

	test_module = f'verif.{test_module}'
	
	test_config = importlib.import_module(test_module).__doc__
	test_config = tomllib.loads(test_config)
	test_config.setdefault('parameters', dict())
	test_config.setdefault('defines', dict())

	if test_config.get('wrap_top'):
		test_config['sources'].append('verif/templates/top_wrapper.sv')
		test_config['defines']['TOP_WRAPPER_NAME'] = test_config['dut'] + '_wrapped'
		test_config['defines']['TOP_WRAPPER_PARAMETERS'] = test_config['wrap_top_parameters']
		test_config['defines']['TOP_WRAPPER_DECLARATIONS'] = test_config['wrap_top_declarations']
		test_config['defines']['TOP_WRAPPER_TOP'] = test_config['dut']
		test_config['dut'] = test_config['defines']['TOP_WRAPPER_NAME']
	
	runner.build(
		sources=test_config['sources'],
		includes=[proj_path / 'design' / 'include'],
		defines=test_config['defines'],
		parameters=test_config['parameters'],
		hdl_toplevel=test_config['dut'],
		build_dir=test_path / 'build',
	)

	runner.test(
		test_module=test_module,
		hdl_toplevel=test_config['dut'],
		parameters=test_config['parameters'],
		build_dir=test_path / 'build',
		test_dir=test_path / 'test',
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
