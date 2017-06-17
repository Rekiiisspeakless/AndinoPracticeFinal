int main() {
	int a;
	int b = 0;
	int c = 1 / 2 + (3 % (3 - 1) * 5);
	a = c;
	int d = 10 % (1 + (a * (b + 5) - c) / 2);
	a = a + 100;
	a = a / 2;
	a = a - 3;
	a = a * 2;
	a = a % 2;
	digitalWrite(13, HIGH);
	delay(b);
	digitalWrite(13, LOW);
	delay(b);
	return 0;
}
