import os

from cto_ai import prompt, sdk, ux


def main():
    repo = prompt.input(
        name="repo",
        message="Which application do you want to deploy?",
        allowEmpty=False,
    )

    # Add your workflow code here
    # os.system("ls -asl")
    # sdk.log("Here is how you can send logs")
    # ux.print(f"🚀 {repo}'s successful deployment has been recorded!")

    # # Send deployment succeeded event
    # event = {
    #     "event_name": "deployment",
    #     "event_action": "succeeded",
    #     "branch": "main",
    #     "repo": repo
    # }
    # sdk.track([], "", event)


if __name__ == "__main__":
    main()
