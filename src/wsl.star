# System Imports
system_variables = import_module("github.com/logos-co/wakurtosis/src/system_variables.star")

# Module Imports
files = import_module(system_variables.FILE_HELPERS_MODULE)

def create_wsl_config():
    
    template_data = None

    # Traffic simulation parameters
    wsl_yml_template = """
        general:
        
            debug_level : "DEBUG"

            targets_file : "./targets/targets.json"

            prng_seed : 0

            # Simulation time in seconds
            simulation_time : 1000

            # Message rate in messages per second
            msg_rate : 10
            
            # Packet size in bytes
            min_packet_size : 2
            max_packet_size : 1024
    """

    artifact_id = render_templates(
        config={
            "wsl.yml": struct(
                template=wsl_yml_template,
                data=template_data,
            )
        }
    )

    return artifact_id

def create_wsl_targets(services):
    
    # Get private ip and ports of all nodes
    template_data = files.generate_template_data(services, services, system_variables.WAKU_TCP_PORT)

    # Template
    template = """
        {{.targets}}
    """

    artifact_id = render_templates(
        config={
            "targets.json": struct(
                template=template,
                data=template_data,
            )
        }
    )

    return artifact_id

def set_up_wsl(services):
    
    # Generate simulation config
    wsl_config = create_wsl_config()

    # Create targets.json
    wsl_targets = create_wsl_targets(services)

    wsl_service = add_service(
        service_id="wsl",
        config=struct(
            image=WSL_IMAGE,
            ports={},
            files={
                WSL_CONFIG_PATH : wsl_config,
                WSL_TARGETS_PATH : wsl_targets,
            },
            # cmd=["python3", "/wsl/wsl.py",],
            cmd=["python3", "wsl.py"]
            # cmd=["sleep 1000",],

            # entrypoint = ["/bin/bash", "-l", "-c",],
        )
    )

    print('kurtosis service logs -f wakurtosis SERVICE-GUID')
    
    return wsl_service