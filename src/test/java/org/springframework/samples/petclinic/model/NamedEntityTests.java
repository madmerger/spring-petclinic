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
package org.springframework.samples.petclinic.model;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class NamedEntityTests {

	@Test
	void nameGetterSetter() {
		NamedEntity entity = new NamedEntity() {
		};
		entity.setName("test");
		assertThat(entity.getName()).isEqualTo("test");
	}

	@Test
	void toStringReturnsName() {
		NamedEntity entity = new NamedEntity() {
		};
		entity.setName("TestEntity");
		assertThat(entity.toString()).isEqualTo("TestEntity");
	}

	@Test
	void toStringReturnsNullPlaceholderWhenNameIsNull() {
		NamedEntity entity = new NamedEntity() {
		};
		assertThat(entity.toString()).isEqualTo("<null>");
	}

	@Test
	void inheritsBaseEntityId() {
		NamedEntity entity = new NamedEntity() {
		};
		entity.setId(99);
		assertThat(entity.getId()).isEqualTo(99);
		assertThat(entity.isNew()).isFalse();
	}

}
