FROM heroku/jvm

ADD ./twitalytics.jar /app/user/

ENTRYPOINT ["java", "-jar", "twitalytics.jar", "-p", "$PORT"]
