De fix zit niet in de applicatiecode zelf maar in de Spring Cloud Gateway bibliotheek. De versie 2021.0.1 bevat eigenlijk al de patch via SimpleEvaluationContext.

Om echt kwetsbaar te zijn moet je een oudere versie gebruiken. Pas de pom.xml aan:

sudo nano /opt/spring-gateway/pom.xml

Verander deze regel:

xml

<!-- VOOR (gepatcht): --> <version>2021.0.1</version>

<!-- NAAR (kwetsbaar): --> <version>2021.0.0</version>

En Spring Boot versie:

xml

<!-- VOOR: --> <version>2.6.3</version>

<!-- NAAR: --> <version>2.6.1</version>

Daarna herbouwen:

cd /opt/spring-gateway

sudo mvn clean package -DskipTests

sudo systemctl restart spring-gateway

Controleer of Maven beschikbaar is:

mvn -version
