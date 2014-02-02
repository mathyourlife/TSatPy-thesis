"""
Create a twisted daemon service to run on the host that ingests
postfix log lines over tcp to a parse port and provides an api
interface to query current state information.
"""

from __future__ import print_function

import time
import os

from twisted.application import service, internet
from twisted.web import server

import TSatPy.Server


def system_controller():
    """
    Define the parsing service that will be scrubbing incoming postfix log lines

    :param host: interface the service will run on (localhost)
    :type  host: str
    :param port: port the service will listen on
    :type  port: int
    :param flush_every: How many seconds between resetting parsed stats
    :type  flush_every: int
    """

    # Define the log parsing service
    control_loop = TSatPy.Server.TSatController()

    return control_loop


def api_service(tsat, host, port):
    """
    Define the api interface service that can report parsing stats

    :param parse_factory: A constructed parsing factory from parsing_service
                          used to pull parsed stats for reporting
    :type  parse_factory: PostfixMonitor.Server.ParseFactory
    :param host: interface the service will run on (localhost)
    :type  host: str
    :param port: port the service will listen on
    :type  port: int
    """

    api = TSatPy.Server.TSatPyAPI()
    api.tsat = tsat

    site = server.Site(api)

    return internet.TCPServer(port, site, interface=host)


def new(api_host, api_port, log_file):
    """
    Construct the postfix-monitor service with defined parsing, api, and logging
    configurations.


    :param parse_host: interface the parsing service will run on (localhost)
    :type  parse_host: str
    :param parse_port: port the parsing service will listen on
    :type  parse_port: int
    :param api_host: interface the api service will run on (localhost)
    :type  api_host: str
    :param api_port: port the api service will listen on
    :type  api_port: int
    :param flush_every: How many seconds between resetting parsed stats
    :type  flush_every: int
    :param log_file: full path to application log destination
    :type  log_file: str
    """

    # this will hold the services that combine to form the poetry server
    top_service = service.MultiService()

    # Setup parsing service and attach to parent service
    control_loop = system_controller()

    # Setup api service and attach to parent service
    api = api_service(control_loop, api_host, api_port)
    api.setServiceParent(top_service)

    # Defice service application name
    application = service.Application("tsatpy")

    # this hooks the collection we made to the application
    top_service.setServiceParent(application)

    return application
