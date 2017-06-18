int main() {
	///////////////fundemental
	/*int a;
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
	delay((b + c) * 1000);*/
	//////////////////compare
	/*int a = 1;
	if (a == 1) {
		int a = 6000;
		digitalWrite(13, HIGH);
		delay(a);
	}
	if (a != 0) {
		int a = 5000;
		digitalWrite(13, LOW);
		delay(a);
	}
	if (a >= 0) {
		int a = 4000;
		digitalWrite(13, HIGH);
		delay(a);
	}
	if (a <= 2) {
		int a = 3000;
		digitalWrite(13, LOW);
		delay(a);
	}

	if (a > 0) {
		//
		int a = 2000;
		digitalWrite(13, HIGH);
		delay(a);
	}
	if (a < 2) {
		int a = 1000;
		digitalWrite(13, LOW);
		delay(a);
	}*/
	////////////////if-else
	/*int a = 0;
	if (a) {
		int a = 2000;
		digitalWrite(13, HIGH);
		delay(a);
	}
	else {
		int a = 5000;
		digitalWrite(13, LOW);
		delay(a);
	}
	a = 6;*/

	///////////////and-or-not
	/*int a = 0;
	int b = 1;
	int c;*/
	////////NOT////
	/*c = !a;
	digitalWrite(13, HIGH);
	delay(c * 2000);
	digitalWrite(13, LOW);
	delay(5000);*/

	/////OR/////
	/*c = (a || b) * 2000;
	digitalWrite(13, HIGH);
	delay(c);
	digitalWrite(13, LOW);
	delay(1000);*/

	/////AND//////
	/*c = (!a && b) * 5000;
	digitalWrite(13, HIGH);
	delay(c);
	digitalWrite(13, LOW);
	delay(1000); */

	/*c = (a || b) * 2000;
	digitalWrite(13, HIGH);
	delay(c);
	c = (!a && b) * 5000;
	digitalWrite(13, LOW);
	delay(c);
	c = (a && b) * 5000;
	digitalWrite(13, LOW);
	delay(c);
	c = (a || !b) * 2000;
	digitalWrite(13, HIGH);
	delay(c);*/
	
	///////////WHILE//////
	int a = 4;
	while (a > 0) {
		int b = 0;
		b = a * 1000;
		digitalWrite(13, HIGH);
		delay(b);
		digitalWrite(13, LOW);
		delay(1000);
		a = a - 1;
	}
	digitalWrite(13, LOW);
	delay(a * 1000);
	return 0;
}

