int main() {
	int a;
	int b = 0;
	int c = 1 / 2 + (3 % (3 - 1) * 5);
	//c = 5
	a = c;
	a = c + 1;
	// a = 6
	int d = 14 % (1 + (a * (b + 5) - c) / 2);
	// d = 1
	a = a + 100;
	a = a / 2;
	a = a - 3;
	a = a * 2;
	a = a % 2;
	//a = 0
	digitalWrite(13, HIGH);
	// 1
	delay((a + d) * 1000);
	digitalWrite(13, LOW);
	// 5
	delay((b + c) * 1000);
	return 0;
}
