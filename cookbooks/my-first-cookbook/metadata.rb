name 'my-first-cookbook'
maintainer 'Alex Katsero'
maintainer_email 'alexanderkatsero@gmail.com'
description 'Sets up automatic-pancake app'
version '0.2.0'
chef_version '>= 12.14' if respond_to?(:chef_version)

depends "git"
depends "nodejs"
