import prompt from "prompts";

export default async function determineTemplate() {
  const response = await prompt({
    type: "select",
    name: "template",
    message: "Pick a template for your setup",
    choices: [
      { title: "Headless (Default)", value: "server" },
      { title: "Desktop", value: "desktop" },
      {
        title: "Personal Desktop",
        value: "personal",
      },
    ],
    instructions: false,
  });
  return response.template;
}
