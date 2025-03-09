Vagrant.configure("2") do |config|
  config.vm.define "apache-ftps-server" do |apache_server|
    apache_server.vm.box = "debian/bookworm64"

    # Red privada para la VM
    apache_server.vm.network "private_network", ip: "192.168.56.101"

    # Configuración de la memoria
    apache_server.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end

    # Configuración del nombre del servidor
    apache_server.vm.hostname = "apache-ftps-server"

    # Carpetas sincronizadas
    apache_server.vm.synced_folder "x1", "/var/www/x1", create: true
    apache_server.vm.synced_folder "x2", "/var/www/x2", create: true
    apache_server.vm.synced_folder "./perfect-html-education/html", "/var/www/perfect-html-education/html", create: true

    # Aprovisionamiento de la máquina
    apache_server.vm.provision "shell", inline: <<-SHELL
      # Actualizar los repositorios e instalar dependencias
      sudo apt update
      sudo apt install -y apache2 vsftpd openssl git dos2unix

      # Habilitar módulos necesarios para Apache
      sudo a2enmod ssl
      sudo a2enmod rewrite
      sudo systemctl restart apache2

      # Configuración de Apache para x1
      sudo cp /vagrant/x1.conf /etc/apache2/sites-available/x1.conf
      sudo a2ensite x1.conf

      # Configuración de Apache para x2 (servidor FTP)
      sudo cp /vagrant/x2.conf /etc/apache2/sites-available/x2.conf
      sudo a2ensite x2.conf

      # Configuración de Apache para perfect-html-education
      sudo cp /vagrant/perfect-html-education.conf /etc/apache2/sites-available/perfect-html-education.conf
      sudo a2ensite perfect-html-education.conf

      sudo systemctl restart apache2

      # Crear un usuario FTP
      sudo useradd -m ftpuser -s /bin/bash
      echo "ftpuser:password" | sudo chpasswd

      # Crear usuarios con nombre y apellido
      sudo sh -c "echo -n 'nico:' >> /etc/apache2/.htpasswd"
      sudo sh -c "openssl passwd -apr1 'nombre'>> /etc/apache2/.htpasswd"

      sudo sh -c "echo -n 'sanchez:' >> /etc/apache2/.htpasswd"
      sudo sh -c "openssl passwd -apr1 'apellido'>> /etc/apache2/.htpasswd"


      # Crear certificados SSL autofirmados para Apache y FTP
      sudo mkdir -p /etc/ssl/private
      sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/private/vsftpd.key \
        -out /etc/ssl/certs/vsftpd.crt \
        -subj "/C=ES/ST=Andalucia/L=Granada/O=miempresa/OU=IT Department/CN=example.com"


      sudo chmod 600 /etc/ssl/private/vsftpd.key
      sudo chmod 644 /etc/ssl/certs/vsftpd.crt

      # Copiar configuración de vsftpd desde el directorio de Vagrant
      sudo cp /vagrant/vsftpd.conf /etc/vsftpd.conf
      # Corrección con dos2unix para que el 
      sudo dos2unix /etc/vsftpd.conf 

      # Reiniciar vsftpd con la nueva configuración
      sudo systemctl restart vsftpd
      sudo systemctl enable vsftpd

      # Crear logs para vsftpd
      sudo touch /var/log/vsftpd.log
      sudo chmod 640 /var/log/vsftpd.log
      sudo chown root:adm /var/log/vsftpd.log

      # Configuración del archivo hosts
      echo "192.168.56.101    x1" | sudo tee -a /etc/hosts
      echo "192.168.56.101    x2" | sudo tee -a /etc/hosts
      echo "192.168.56.101    perfect-html-education" | sudo tee -a /etc/hosts


      # Reiniciar Apache para aplicar cambios finales
      sudo systemctl restart apache2
    SHELL
  end
end
