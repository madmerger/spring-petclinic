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
package org.springframework.samples.petclinic.vet;

import java.util.List;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class VetsTests {

	@Test
	void getVetListReturnsEmptyListByDefault() {
		Vets vets = new Vets();
		List<Vet> list = vets.getVetList();
		assertThat(list).isNotNull();
		assertThat(list).isEmpty();
	}

	@Test
	void getVetListReturnsSameInstance() {
		Vets vets = new Vets();
		List<Vet> list1 = vets.getVetList();
		List<Vet> list2 = vets.getVetList();
		assertThat(list1).isSameAs(list2);
	}

	@Test
	void canAddVetsToList() {
		Vets vets = new Vets();
		Vet vet = new Vet();
		vet.setFirstName("James");
		vet.setLastName("Carter");
		vets.getVetList().add(vet);
		assertThat(vets.getVetList()).hasSize(1);
		assertThat(vets.getVetList().get(0).getFirstName()).isEqualTo("James");
	}

	@Test
	void xmlRootElementAnnotationPresent() {
		assertThat(Vets.class.isAnnotationPresent(jakarta.xml.bind.annotation.XmlRootElement.class)).isTrue();
	}

}
