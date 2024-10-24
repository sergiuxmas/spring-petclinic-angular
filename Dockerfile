FROM node:16-alpine as build
WORKDIR /app
RUN rm -rf node_modules package-lock.json
COPY . /app/
#RUN npm cache clean --force
RUN npm install -g @angular/cli@16.2.1 --force && \
    npm install --force
#EXPOSE 4200
RUN ng build --base-href=/petclinic/ --deploy-url=/petclinic/
#RUN ng build --prod --base-href=/petclinic/ --deploy-url=/petclinic/
#ng serve
#CMD ["ng", "version"]

FROM nginx:alpine as final
COPY --from=build /app/dist /usr/share/nginx/html/petclinic/
# Create a custom NGINX configuration in /etc/nginx/conf.d/
RUN echo 'server {' > /etc/nginx/conf.d/petclinic.conf && \
    echo '    listen 80 default_server;' >> /etc/nginx/conf.d/petclinic.conf && \
    echo '    root /usr/share/nginx/html;' >> /etc/nginx/conf.d/petclinic.conf && \
    echo '    index index.html;' >> /etc/nginx/conf.d/petclinic.conf && \
    echo '' >> /etc/nginx/conf.d/petclinic.conf && \
    echo '    location /petclinic/ {' >> /etc/nginx/conf.d/petclinic.conf && \
    echo '        alias /usr/share/nginx/html/petclinic/dist/;' >> /etc/nginx/conf.d/petclinic.conf && \
    echo '        try_files \$uri\$args \$uri\$args/ /petclinic/index.html;' >> /etc/nginx/conf.d/petclinic.conf && \
    echo '    }' >> /etc/nginx/conf.d/petclinic.conf && \
    echo '}' >> /etc/nginx/conf.d/petclinic.conf
EXPOSE 80
# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
