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

import java.time.LocalDate;
import java.util.Collection;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class PetTests {

	@Test
	void addVisitAddsToCollection() {
		Pet pet = new Pet();
		Visit visit = new Visit();
		visit.setDescription("checkup");
		pet.addVisit(visit);
		assertThat(pet.getVisits()).hasSize(1);
		assertThat(pet.getVisits()).contains(visit);
	}

	@Test
	void getVisitsReturnsSortedByDate() {
		Pet pet = new Pet();

		Visit visit1 = new Visit();
		visit1.setDate(LocalDate.of(2023, 3, 1));
		visit1.setDescription("first");

		Visit visit2 = new Visit();
		visit2.setDate(LocalDate.of(2023, 1, 1));
		visit2.setDescription("second");

		Visit visit3 = new Visit();
		visit3.setDate(LocalDate.of(2023, 2, 1));
		visit3.setDescription("third");

		pet.addVisit(visit1);
		pet.addVisit(visit2);
		pet.addVisit(visit3);

		Collection<Visit> visits = pet.getVisits();
		assertThat(visits).isNotEmpty();
		assertThat(visits).hasSize(3);
	}

	@Test
	void birthDateGetterSetter() {
		Pet pet = new Pet();
		LocalDate date = LocalDate.of(2020, 5, 15);
		pet.setBirthDate(date);
		assertThat(pet.getBirthDate()).isEqualTo(date);
	}

	@Test
	void typeGetterSetter() {
		Pet pet = new Pet();
		PetType type = new PetType();
		type.setName("cat");
		pet.setType(type);
		assertThat(pet.getType()).isEqualTo(type);
		assertThat(pet.getType().getName()).isEqualTo("cat");
	}

	@Test
	void equalsAndHashCode() {
		Pet pet1 = new Pet();
		pet1.setId(1);
		pet1.setName("Buddy");

		Pet pet2 = new Pet();
		pet2.setId(1);
		pet2.setName("Buddy");

		Pet pet3 = new Pet();
		pet3.setId(2);
		pet3.setName("Max");

		assertThat(pet1.getId()).isEqualTo(pet2.getId());
		assertThat(pet1.getId()).isNotEqualTo(pet3.getId());
	}

}
