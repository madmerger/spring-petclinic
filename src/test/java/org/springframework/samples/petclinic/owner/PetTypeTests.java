/*
 * Copyright 2012-2025 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.springframework.samples.petclinic.owner;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class PetTypeTests {

	@Test
	void nameGetterSetter() {
		PetType type = new PetType();
		type.setName("dog");
		assertThat(type.getName()).isEqualTo("dog");
	}

	@Test
	void toStringReturnsName() {
		PetType type = new PetType();
		type.setName("cat");
		assertThat(type.toString()).isEqualTo("cat");
	}

	@Test
	void toStringReturnsNullPlaceholderWhenNameIsNull() {
		PetType type = new PetType();
		assertThat(type.toString()).isEqualTo("<null>");
	}

	@Test
	void idGetterSetter() {
		PetType type = new PetType();
		type.setId(5);
		assertThat(type.getId()).isEqualTo(5);
	}

}
