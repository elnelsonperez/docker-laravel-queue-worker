#!/bin/sh

if [ -z "$QUEUE_CONNECTION" ]; then
	QUEUE_CONNECTION="redis"
fi

if [ -z "$QUEUE_NAME" ]; then
	QUEUE_NAME="default"
fi

if [ -z "$EXTRA_ARGS" ]; then
	EXTRA_ARGS=""
fi

if [ -z "$LARAVEL_HORIZON" ]; then
	LARAVEL_HORIZON=false
fi

PHP_MEMORY_LIMIT=${PHP_MEMORY_LIMIT:-512}
sed -e "s~%%MEMORY_LIMIT%%~${PHP_MEMORY_LIMIT}m~" \
    /opt/etc/custom-php.ini.tpl > /usr/local/etc/php/conf.d/custom-php.ini

if [ "$LARAVEL_HORIZON" = "true" ] || [ "$LARAVEL_HORIZON" = "1" ] ; then
	cp /etc/supervisor/conf.d/laravel-horizon.conf.tpl /etc/supervisor/supervisord.conf
else
	sed -e "s~%%QUEUE_CONNECTION%%~$QUEUE_CONNECTION~" \
		-e "s~%%QUEUE_NAME%%~$QUEUE_NAME~" \
		-e "s~%%MEMORY_LIMIT%%~$PHP_MEMORY_LIMIT~" \
		-e "s~%%EXTRA_ARGS%%~$EXTRA_ARGS~" \
		/etc/supervisor/conf.d/laravel-worker.conf.tpl > /etc/supervisor/supervisord.conf
fi

exec supervisord --nodaemon --configuration /etc/supervisor/supervisord.conf
