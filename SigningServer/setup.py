from setuptools import setup , find_packages

setup(
    name='moca',
    #packages=['moca'],

    description='Simple microblog example using Flask',
    packages=find_packages(),
    entry_points='''
        [flask.commands]
        initdb=moca.moca:initdb_command
        ''',

    include_package_data=True,
    install_requires=[
        'flask',
    ],
)

