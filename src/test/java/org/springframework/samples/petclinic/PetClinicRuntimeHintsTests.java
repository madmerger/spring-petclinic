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
package org.springframework.samples.petclinic;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.aot.hint.RuntimeHints;
import org.springframework.aot.hint.predicate.RuntimeHintsPredicates;
import org.springframework.samples.petclinic.model.BaseEntity;
import org.springframework.samples.petclinic.model.Person;
import org.springframework.samples.petclinic.vet.Vet;

import static org.assertj.core.api.Assertions.assertThat;

class PetClinicRuntimeHintsTests {

	private RuntimeHints hints;

	@BeforeEach
	void setup() {
		hints = new RuntimeHints();
		new PetClinicRuntimeHints().registerHints(hints, getClass().getClassLoader());
	}

	@Test
	void dbResourcePatternRegistered() {
		assertThat(RuntimeHintsPredicates.resource().forResource("db/schema.sql")).accepts(hints);
	}

	@Test
	void messagesResourcePatternRegistered() {
		assertThat(RuntimeHintsPredicates.resource().forResource("messages/messages.properties")).accepts(hints);
	}

	@Test
	void mysqlDefaultConfResourcePatternRegistered() {
		assertThat(hints.resources()
			.resourcePatternHints()
			.anyMatch(hint -> hint.getIncludes().stream().anyMatch(p -> p.getPattern().contains("mysql-default-conf"))))
			.isTrue();
	}

	@Test
	void baseEntitySerializationRegistered() {
		assertThat(RuntimeHintsPredicates.serialization().onType(BaseEntity.class)).accepts(hints);
	}

	@Test
	void personSerializationRegistered() {
		assertThat(RuntimeHintsPredicates.serialization().onType(Person.class)).accepts(hints);
	}

	@Test
	void vetSerializationRegistered() {
		assertThat(RuntimeHintsPredicates.serialization().onType(Vet.class)).accepts(hints);
	}

}
