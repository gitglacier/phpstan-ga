#!/bin/sh -l

# Add Github host key authentication.
/usr/bin/ssh -T -oStrictHostKeyChecking=accept-new git@github.com || true

IGNORE_PLATFORM_REQS=""
if [ "$CHECK_PLATFORM_REQUIREMENTS" = "false" ]; then
    IGNORE_PLATFORM_REQS="--ignore-platform-reqs"
fi

NO_DEV="--no-dev"
if [ "$REQUIRE_DEV" = "true" ]; then
    NO_DEV=""
fi

COMPOSER_COMMAND="composer install --no-scripts --no-progress $NO_DEV $IGNORE_PLATFORM_REQS"
echo "::group::$COMPOSER_COMMAND"
$COMPOSER_COMMAND
echo "::endgroup::"

echo "::group::Installed PHPStan extensions"
composer show | grep phpstan
echo "::endgroup::"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

## Lint must pass, or else die
#./vendor/bin/parallel-lint --checkstyle --exclude vendor . | reviewdog -fail-on-error -f=checkstyle -reporter="${INPUT_REPORTER}" -level="${INPUT_LEVEL}" && \
#( \
#./vendor/bin/phpstan --version ; \
#./vendor/bin/phpstan analyse --configuration=phpstan-ci.neon --no-progress --no-interaction --error-format=checkstyle | reviewdog -fail-on-error -f=checkstyle -reporter="${INPUT_REPORTER}" -level="${INPUT_LEVEL}" ; \
#./vendor/friendsofphp/php-cs-fixer/php-cs-fixer --version ; \
#./vendor/friendsofphp/php-cs-fixer/php-cs-fixer fix --dry-run --format=checkstyle | reviewdog -fail-on-error -f=checkstyle -reporter="${INPUT_REPORTER}" -level="${INPUT_LEVEL}" ; \
#)

./vendor/bin/parallel-lint --version && \
./vendor/bin/parallel-lint --checkstyle --exclude vendor . | reviewdog -f=checkstyle -reporter="${INPUT_REPORTER}" -level="${INPUT_LEVEL}" && \
./vendor/bin/phpstan --version && \
./vendor/bin/phpstan analyse --configuration=phpstan-ci.neon --no-progress --no-interaction --error-format=checkstyle | reviewdog -fail-on-error -f=checkstyle -reporter="${INPUT_REPORTER}" -level="${INPUT_LEVEL}" && \
./vendor/friendsofphp/php-cs-fixer/php-cs-fixer --version && \
./vendor/friendsofphp/php-cs-fixer/php-cs-fixer fix --dry-run --format=checkstyle | reviewdog -f=checkstyle -reporter="${INPUT_REPORTER}" -level="${INPUT_LEVEL}" && \
