#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MAX_TABLE_SIZE 400
class SymbolTableEntry {
public:
	std::string id;
	int scope;
	int offset;
};
class SymbolTable {
public:
	SymbolTableEntry table[400];
	int cur_count;
	int cur_scope;
	SymbolTable() {
		cur_count = 0;
		cur_scope = 0;
	}
	void install(char* a, int offset) {
		if (cur_count >= MAX_TABLE_SIZE) {

		}
		else {
			table[cur_count].scope = cur_scope;
			table[cur_count].id = a;
			table[cur_count].offset = offset;
			cur_count++;
		}
	}
	int lookup(char a[]) {
		if (cur_count == 0) return -1;
		for (int i = cur_count - 1; i >= 0; i--) {
			if (a == table[i].id)
				return i;
		}
		return -1;
	}
	void pop() {
		if (cur_count == 0) return;
		int i;
		for (i = cur_count - 1; i >= 0; i--) {
			if (table[i].scope != cur_scope) break;
		}
		cur_count = i + 1;
	}
	void updateScope(int scope) {
		cur_scope = scope;
	}
};