How to reproduce the bug:
1. Clone the rep
2. docker-compose up -d --build
3. docker-compose exec php composer install
4. open src/example.php
5. see error in log
6. docker-compose down
7. comment single line in .env
8. docker-compose up -d
9. open src/example.php - no errors, linter works correctly

not reproduces the bug^
